// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import EventKit
import Observation
import WatchConnectivity

@MainActor @Observable
final class CalendarSelection: NSObject, WCSessionDelegate {
    private nonisolated static let contextKey = "hiddenCalendars"

    #if os(watchOS)
    private(set) var hidden = UserDefaults.standard.array(forKey: CalendarSelection.contextKey) as? [[String]] ?? []
    #else
    @ObservationIgnored private var pending: [[String]]?
    #endif

    override init() {
        super.init()
        guard WCSession.isSupported(), !Demo.active else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private static func name(_ calendar: EKCalendar) -> [String] {
        [calendar.calendarIdentifier, calendar.title, calendar.source?.title ?? ""]
    }

    #if os(watchOS)
    func shows(_ calendar: EKCalendar) -> Bool {
        let name = Self.name(calendar)
        return !hidden.contains { $0.count == 3 && ($0[0] == name[0] || ($0[1] == name[1] && $0[2] == name[2])) }
    }

    private func adopt(_ received: [[String]]) {
        hidden = received
        UserDefaults.standard.set(received, forKey: Self.contextKey)
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard let received = session.receivedApplicationContext[Self.contextKey] as? [[String]] else { return }
        Task { @MainActor in self.adopt(received) }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let received = applicationContext[Self.contextKey] as? [[String]] else { return }
        Task { @MainActor in self.adopt(received) }
    }
    #else
    func send(hidden calendars: [EKCalendar]) {
        pending = calendars.map(Self.name)
        flush()
    }

    private func flush() {
        let session = WCSession.default
        guard let pending, session.activationState == .activated, session.isPaired, session.isWatchAppInstalled else { return }
        do {
            try session.updateApplicationContext([Self.contextKey: pending])
            self.pending = nil
        } catch {}
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in self.flush() }
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in self.flush() }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
