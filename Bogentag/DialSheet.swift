// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

struct DialSheet: View {
    @Environment(SunLocation.self) private var location
    @Environment(Timing.self) private var timing
    @Environment(CalendarStore.self) private var calendars
    @Environment(\.dismiss) private var dismiss

    @State private var panel: Panel?
    @State private var showsSettings = false

    enum Panel: String, Identifiable {
        case timer
        case stopwatch

        var id: String { rawValue }
    }

    var body: some View {
        content.background(Palette.night)
    }

    @ViewBuilder
    private var content: some View {
        #if DEBUG
        if Demo.page == "gallery" {
            GalleryView(reading: Reading(at: Demo.now(.now), latitude: Demo.place.latitude, longitude: Demo.place.longitude))
        } else {
            phone
        }
        #else
        phone
        #endif
    }

    /// The dial above its buttons, or beside them in a window wider than tall.
    private var phone: some View {
        NavigationStack {
            dialAndButtons
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showsSettings = true } label: { Image(systemName: "gearshape") }
                            .accessibilityLabel("Settings")
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .background(Palette.night)
        }
        .tint(Palette.sun)
    }

    private var dialAndButtons: some View {
        GeometryReader { geometry in
            let layout = geometry.size.width > geometry.size.height
                ? AnyLayout(HStackLayout(spacing: 24))
                : AnyLayout(VStackLayout(spacing: 12))
            layout {
                DialScreen()
                    .padding()
                VStack(spacing: 12) {
                    ShadowBearing()
                    HStack(spacing: 6) {
                        Button("Timer") { panel = .timer }
                            .buttonStyle(ChoiceButtonStyle(selected: timing.timer != nil))
                        Button("Stopwatch") { panel = .stopwatch }
                            .buttonStyle(ChoiceButtonStyle(selected: timing.stopwatch != nil))
                    }
                }
                .padding(.bottom)
                .frame(maxWidth: 480)
            }
        }
        .padding(.horizontal)
        .onAppear {
            panel = Demo.page.flatMap(Panel.init)
        }
        .sheet(isPresented: $showsSettings) {
            if let place = location.place {
                SettingsView(calendars: calendars, place: place)
            }
        }
        .sheet(item: $panel) { panel in
            NavigationStack {
                Group {
                    switch panel {
                    case .timer: TimerScreen()
                    case .stopwatch: StopwatchScreen()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { self.panel = nil }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .background(Palette.bezel)
            }
            .tint(Palette.sun)
            .environment(location)
            .environment(timing)
            .presentationDetents([.medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationBackground(Palette.bezel)
            .presentationDragIndicator(.visible)
        }
    }
}

struct ShadowBearing: View {
    @Environment(SunLocation.self) private var location

    var body: some View {
        TimelineView(.everyMinute) { context in
            let shadow = location.place.flatMap { place in
                Shadow(of: Reading(at: Demo.now(context.date), latitude: place.latitude, longitude: place.longitude))
            }
            let degrees = shadow.map { (Int($0.bearing.rounded()) + 360) % 360 } ?? 0
            Text("SHADOW \(String(format: "%03d", degrees))° TRUE")
                .font(.footnote.weight(.medium).monospacedDigit())
                .tracking(1)
                .foregroundStyle(Palette.label)
                .opacity(shadow == nil ? 0 : 1)
                .accessibilityLabel("Shadow points \(degrees) degrees from true north")
                .accessibilityHidden(shadow == nil)
        }
    }
}
