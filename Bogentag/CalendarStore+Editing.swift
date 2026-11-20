// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import EventKit
import Foundation

extension CalendarStore {
    func refresh() {
        if !Demo.active { store.refreshSourcesIfNecessary() }
        reload()
    }

    func edited(_ event: EKEvent) {
        if !Demo.active { event.refresh() }
        reload()
    }

    func retime(_ event: EKEvent, start: Date, end: Date, span: EKSpan) throws {
        event.startDate = start
        event.endDate = end
        do {
            try store.save(event, span: span, commit: true)
        } catch {
            event.rollback()
            throw error
        }
        reload()
    }

    func editingStore(for event: EKEvent) -> EKEventStore? {
        Demo.active || !event.calendar.allowsContentModifications ? nil : store
    }

    var momentCalendar: EKCalendar? {
        Demo.active ? nil : store.defaultCalendarForNewEvents
    }

    func addMoment(at instant: Date, title: String) throws {
        guard let calendar = momentCalendar else { throw MomentError.noCalendar }
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = instant
        event.endDate = instant
        event.calendar = calendar
        event.addAlarm(EKAlarm(relativeOffset: 0))
        try store.save(event, span: .thisEvent, commit: true)
    }
}
