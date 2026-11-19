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
    private(set) var status: Status = .undetermined

    static let moveThreshold: CLLocationDistance = 10_000

    private let manager = CLLocationManager()
    private var wanted = false

    override init() {
        super.init()
        if Demo.active {
            place = Demo.place
            status = .fixed
            return
        }
        place = AppGroup.loadPlace()
        if place != nil { status = .fixed }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        follow(manager.authorizationStatus)
    }

    func start() {
        guard !Demo.active else { return }
        wanted = true
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            follow(manager.authorizationStatus)
        }
    }

    func stop() {
        wanted = false
        manager.stopUpdatingLocation()
    }

    private func follow(_ authorization: CLAuthorizationStatus) {
        switch authorization {
        case .notDetermined:
            if place == nil { status = .undetermined }
        case .denied, .restricted:
            forget()
        default:
            if place == nil { status = .waiting }
            if wanted { manager.startUpdatingLocation() }
        }
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
        let authorization = manager.authorizationStatus
        Task { @MainActor in self.follow(authorization) }
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
