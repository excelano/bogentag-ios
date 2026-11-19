// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import EventKit
import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(SunLocation.self) private var location
    @State private var calendars = CalendarStore()
    @AppStorage("tourSeen") private var tourSeen = false
    @State private var showsTour = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            if let place = location.place {
                if calendars.access == .fullAccess {
                    DayPager(place: place, calendars: calendars)
                        .environment(calendars)
                } else {
                    calendarGate
                }
            } else {
                locationGate
            }
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active {
                calendars.refresh()
                if location.status != .undetermined { location.start() }
            } else {
                location.stop()
            }
        }
        .onAppear { showsTour = (!tourSeen && !Demo.active) || Demo.page == "tour" }
        .sheet(isPresented: $showsTour, onDismiss: { tourSeen = true }) {
            TourView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged).receive(on: RunLoop.main)) { _ in
            calendars.reload()
        }
    }

    @ViewBuilder private var calendarGate: some View {
        if calendars.access == .notDetermined {
            AccessGate(
                title: "Your calendars",
                message: "Bogentag shows the calendars on this iPhone laid out on the Sun's arc, adds the moments you set to them, and saves the changes you make to an event. Your events stay here and are sent nowhere.",
                actionTitle: "Allow Calendar Access"
            ) { calendars.requestAccess() }
        } else {
            AccessGate(
                title: "Calendar access is off",
                message: "Bogentag needs full access to read your events. Turn it on for Bogentag in Settings, under Calendars.",
                actionTitle: "Open Settings",
                action: openSettings
            )
        }
    }

    @ViewBuilder private var locationGate: some View {
        switch location.status {
        case .undetermined:
            AccessGate(
                title: "Where you are",
                message: "Solar noon, sunrise and sunset depend on where you are. Bogentag uses your approximate location, reads it only while open, and keeps it on this iPhone.",
                actionTitle: "Use Approximate Location"
            ) { location.start() }
        case .denied:
            AccessGate(
                title: "Location access is off",
                message: "Bogentag needs your approximate location to find the Sun's arc where you are. Turn it on for Bogentag in Settings, under Location.",
                actionTitle: "Open Settings",
                action: openSettings
            )
        case .waiting, .fixed:
            ProgressView("Finding where you are")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Palette.night)
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
    }
}

private struct AccessGate: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Palette.line)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.label)
            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(Palette.sun)
                .foregroundStyle(Palette.night)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.night)
    }
}
