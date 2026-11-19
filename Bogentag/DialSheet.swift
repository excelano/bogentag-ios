// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

struct DialSheet: View {
    @Environment(SunLocation.self) private var location
    @Environment(Timing.self) private var timing
    @Environment(CalendarStore.self) private var calendars
    @Environment(\.dismiss) private var dismiss

    @AppStorage("tourSeen") private var tourSeen = false
    @State private var showsTour = false
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
                HStack(spacing: 6) {
                    Button("Timer") { panel = .timer }
                        .buttonStyle(ChoiceButtonStyle(selected: timing.timer != nil))
                    Button("Stopwatch") { panel = .stopwatch }
                        .buttonStyle(ChoiceButtonStyle(selected: timing.stopwatch != nil))
                }
                .padding(.bottom)
                .frame(maxWidth: 480)
            }
        }
        .padding(.horizontal)
        .onAppear {
            if (!tourSeen && !Demo.active) || Demo.page == "tour" { showsTour = true }
            panel = Demo.page.flatMap(Panel.init)
        }
        .sheet(isPresented: $showsSettings) {
            if let place = location.place {
                SettingsView(calendars: calendars, place: place)
            }
        }
        .sheet(isPresented: $showsTour, onDismiss: { tourSeen = true }) {
            TourView().environment(location)
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
