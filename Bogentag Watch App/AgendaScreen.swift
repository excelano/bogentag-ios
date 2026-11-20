// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import BogenzeitUI
import EventKit
import SwiftUI

struct AgendaScreen: View {
    @Environment(SunLocation.self) private var location
    @Environment(\.scenePhase) private var scenePhase
    @State private var calendars = CalendarStore()

    var body: some View {
        Group {
            if let place = location.place {
                if calendars.access == .fullAccess {
                    TimelineView(.everyMinute) { context in
                        AgendaView(calendars: calendars, place: place, now: CalendarDemo.now(context.date))
                    }
                } else {
                    gate
                }
            } else {
                WaitingView()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { calendars.reload() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged).receive(on: RunLoop.main)) { _ in
            calendars.reload()
        }
    }

    private var gate: some View {
        let undetermined = calendars.access == .notDetermined
        return VStack(spacing: 12) {
            Text(undetermined
                 ? "Bogentag shows the rest of your day on the Sun's arc. Your events stay on this watch."
                 : "Bogentag needs full access to read your events. Allow Calendars for Bogentag in Settings, under Privacy & Security.")
                .font(.footnote)
                .foregroundStyle(Palette.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if calendars.requesting {
                ProgressView()
            } else if undetermined {
                Button("Allow Calendars") { calendars.requestAccess() }
            }
        }
        .padding()
    }
}

private struct AgendaView: View {
    let calendars: CalendarStore
    let place: Place
    let now: Date
    @Environment(CalendarSelection.self) private var selection
    @AppStorage(Settings.dialVariantKey, store: AppGroup.defaults) private var variant = Scale.spans.rawValue
    @State private var opened: Set<String> = []

    var body: some View {
        let reading = Reading(at: now, latitude: place.latitude, longitude: place.longitude)
        let solar = reading.day
        let events = calendars.events(from: solar.midnightStart, to: solar.midnightEnd)
            .filter { !$0.isAllDay && selection.shows($0.calendar) && ($0.endDate > now || $0.startDate >= now) }
            .sorted { $0.startDate < $1.startDate }
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(Labels.day(solar.day))
                    .font(.headline)
                    .foregroundStyle(Palette.line)
                if events.isEmpty {
                    Text("NOTHING MORE TODAY")
                        .font(.caption2.weight(.medium))
                        .tracking(0.8)
                        .foregroundStyle(Palette.label)
                }
                ForEach(events, id: \.agendaID) { event in
                    row(event)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }

    private func row(_ event: EKEvent) -> some View {
        let start = Reading(at: event.startDate, latitude: place.latitude, longitude: place.longitude)
        let shown = DisplayedPosition(start, scale: Scale(rawValue: variant) ?? .spans, precision: .low)
        let isOn = event.startDate <= now && now < event.endDate
        let isOpen = opened.contains(event.agendaID)
        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(Color(cgColor: event.calendar.cgColor))
                .frame(width: 7, height: 7)
            VStack(alignment: .leading, spacing: 2) {
                PositionView(shown: shown, size: 17, glyphRadius: 6, lineWidth: 1.5, spacing: 4,
                             color: isOn ? Palette.sun : Palette.line)
                Text(event.title ?? "")
                    .font(.footnote)
                    .foregroundStyle(Palette.secondary)
                    .lineLimit(isOpen ? nil : 2)
                if isOpen {
                    Text(event.startDate == event.endDate
                         ? Labels.clock(event.startDate)
                         : "\(Labels.clock(event.startDate)) – \(Labels.clock(event.endDate))")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(Palette.label)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            if isOpen { opened.remove(event.agendaID) } else { opened.insert(event.agendaID) }
        }
        .accessibilityElement(children: .combine)
    }
}

private extension EKEvent {
    var agendaID: String {
        "\(calendarItemIdentifier)@\(startDate.timeIntervalSince1970)"
    }
}
