// DialScreen.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import BogenzeitUI
import SwiftUI

/// One dial, read for the place in use once a second, and the civil view a
/// tap puts over it (Bogentag spec §2).
struct DialScreen: View {
    @Environment(SunLocation.self) private var location
    @Environment(Timing.self) private var timing
    @AppStorage(Settings.dialVariantKey, store: AppGroup.defaults) private var storedVariant = Scale.spans.rawValue
    @State private var showsCivil = Demo.civil
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    /// The chosen dial, or the one a `--page` launch argument names.
    private var variant: Scale {
        Demo.page.flatMap(Scale.init) ?? Scale(rawValue: storedVariant) ?? .spans
    }

    #if os(watchOS)
    private let isWatch = true
    #else
    private let isWatch = false
    #endif

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = Demo.now(context.date)
            if let place = location.place {
                let reading = Reading(at: now, latitude: place.latitude, longitude: place.longitude)
                let model = DialModel(reading: reading, variant: variant)
                ZStack {
                    DialView(model: model, showsReadout: !showsCivil, showsArcLengths: !isWatch,
                             showsShadow: !isLuminanceReduced, arcs: timing.arcs(on: model, at: now))
                        .opacity(showsCivil ? 0.35 : 1)
                    if showsCivil {
                        CivilView(reading: reading, now: now)
                    }
                }
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { showsCivil.toggle() }
                .accessibilityLabel(showsCivil ? "\(Labels.utcClock(now)) UTC, \(Labels.localClock(now))" : reading.timestamp)
            } else {
                WaitingView()
            }
        }
    }
}

/// What the dial shows until there is a place to compute it for.
struct WaitingView: View {
    @Environment(SunLocation.self) private var location

    var body: some View {
        VStack(spacing: 12) {
            GlyphView(.noon, radius: 18, lineWidth: 3.5, color: Palette.line)
            Text(message)
                .font(.footnote)
                .foregroundStyle(Palette.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            switch location.status {
            case .undetermined:
                Button("Use Location") { location.start() }
            case .waiting, .fixed:
                ProgressView()
            case .denied:
                EmptyView()
            }
        }
        .padding()
    }

    private var message: String {
        switch location.status {
        case .undetermined:
            "Bogentag needs your location to find the Sun's arc."
        case .waiting, .fixed:
            "Finding where you are."
        case .denied:
            "Bogentag needs your location to find the Sun's arc. Allow Location for Bogentag in Settings."
        }
    }
}
