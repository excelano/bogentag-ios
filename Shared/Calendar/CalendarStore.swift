// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import EventKit
import Foundation

/// The calendars on this device, read through EventKit, and which of them
/// the person has chosen to hide.
@MainActor @Observable
final class CalendarStore {
    private(set) var access = EKEventStore.authorizationStatus(for: .event)
    private(set) var calendars: [EKCalendar] = []
    private(set) var hiddenIDs: Set<String>
    private(set) var storeChanges = 0
    private(set) var requesting = false

    @ObservationIgnored let store = EKEventStore()
    @ObservationIgnored private var granted = false

    init() {
        hiddenIDs = Set(UserDefaults.standard.stringArray(forKey: Settings.hiddenCalendarsKey) ?? [])
        reload()
    }

    func requestAccess() {
        requesting = true
        store.requestFullAccessToEvents { @Sendable granted, _ in
            Task { @MainActor in
                self.requesting = false
                self.granted = granted
                self.reload()
            }
        }
    }

    func reload() {
        storeChanges += 1
        if Demo.active {
            access = .fullAccess
            calendars = CalendarDemo.calendars
            return
        }
        access = granted ? .fullAccess : EKEventStore.authorizationStatus(for: .event)
        guard access == .fullAccess else {
            calendars = []
            return
        }
        calendars = store.calendars(for: .event)
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    func isVisible(_ calendar: EKCalendar) -> Bool {
        !hiddenIDs.contains(calendar.calendarIdentifier)
    }

    func setVisible(_ visible: Bool, _ calendar: EKCalendar) {
        if visible {
            hiddenIDs.remove(calendar.calendarIdentifier)
        } else {
            hiddenIDs.insert(calendar.calendarIdentifier)
        }
        UserDefaults.standard.set(Array(hiddenIDs), forKey: Settings.hiddenCalendarsKey)
    }

    func events(from start: Date, to end: Date) -> [EKEvent] {
        _ = storeChanges
        let visible = calendars.filter(isVisible)
        guard !visible.isEmpty else { return [] }
        if Demo.active { return CalendarDemo.events(from: start, to: end, in: visible) }
        return store.events(matching: store.predicateForEvents(withStart: start, end: end, calendars: visible))
    }
}
