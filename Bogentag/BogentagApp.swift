// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI
import UserNotifications

@main
struct BogentagApp: App {
    @State private var location = SunLocation()
    @State private var timing = Timing()
    @State private var calendarSelection = CalendarSelection()

    init() {
        UNUserNotificationCenter.current().delegate = TimerAlert.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(location)
                .environment(timing)
                .environment(calendarSelection)
        }
    }
}
