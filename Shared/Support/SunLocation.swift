// SunLocation.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import CoreLocation
import Observation
import WidgetKit

/// The coordinates the dial is computed for. A fix replaces the place in use
/// only when it is more than ten kilometres away (Bogenzeit spec §5.5);
/// closer moves shift solar noon by less than one readout step. The place in
/// use is kept across launches and shared with the widgets.
@MainActor @Observable
final class SunLocation: NSObject, CLLocationManagerDelegate {
    enum Status: Equatable {
        case undetermined
        case waiting
        case denied
        case fixed
    }

    private(set) var place: Place?
    private(set) var status: Status = .waiting

    static let moveThreshold: CLLocationDistance = 10_000

    private let manager = CLLocationManager()

    override init() {
        super.init()
        if Demo.active {
            place = Demo.place
            status = .fixed
            return
        }
        place = AppGroup.loadPlace()
        if place != nil {
            status = .fixed
        } else if manager.authorizationStatus == .notDetermined {
            status = .undetermined
        }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func start() {
        guard !Demo.active else { return }
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            forget()
        default:
            if place == nil { status = .waiting }
            manager.startUpdatingLocation()
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    private func forget() {
        manager.stopUpdatingLocation()
        status = .denied
        guard place != nil else { return }
        place = nil
        AppGroup.forgetPlace()
        WidgetCenter.shared.reloadAllTimelines()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        Task { @MainActor in self.start() }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let fix = locations.last else { return }
        let latitude = fix.coordinate.latitude
        let longitude = fix.coordinate.longitude
        Task { @MainActor in self.adopt(latitude: latitude, longitude: longitude) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    private func adopt(latitude: Double, longitude: Double) {
        if let place {
            let moved = CLLocation(latitude: place.latitude, longitude: place.longitude)
                .distance(from: CLLocation(latitude: latitude, longitude: longitude))
            if moved < Self.moveThreshold { return }
        }
        let adopted = Place(latitude: latitude, longitude: longitude)
        place = adopted
        status = .fixed
        AppGroup.save(adopted)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
