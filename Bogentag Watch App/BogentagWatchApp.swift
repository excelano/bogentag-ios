// BogentagWatchApp.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI
import UserNotifications

@main
struct BogentagWatchApp: App {
    @State private var location = SunLocation()
    @State private var timing = Timing()
    @State private var calendarSelection = CalendarSelection()

    init() {
        UNUserNotificationCenter.current().delegate = TimerAlert.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(location)
                .environment(timing)
                .environment(calendarSelection)
                .preferredColorScheme(.dark)
        }
    }
}
