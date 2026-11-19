// RootView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI

/// The pages, and the location they need while the app is on screen.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SunLocation.self) private var location

    var body: some View {
        content
            .background(Palette.night)
            .onChange(of: scenePhase, initial: true) {
                if scenePhase == .active {
                    location.start()
                } else {
                    location.stop()
                }
            }
    }

    enum Page: String {
        case dial
        case timer
        case stopwatch
        case day
        case settings
    }

    @State private var page: Page = Demo.page.flatMap(Page.init) ?? .dial

    /// Pages turned with the Digital Crown. The dials take the whole screen,
    /// under the clock watchOS draws in the corner of every app.
    private var content: some View {
        TabView(selection: $page) {
            DialScreen().tag(Page.dial)
            TimerScreen().tag(Page.timer)
            StopwatchScreen().tag(Page.stopwatch)
            DayScreen().tag(Page.day)
            SettingsScreen().tag(Page.settings)
        }
        .tabViewStyle(.verticalPage)
    }
}
