// SettingChoices.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI
import WidgetKit

/// Spans or Kiloseconds dial. The widgets show the same scale, so they are
/// redrawn when it changes.
struct DialVariantChoice: View {
    var title = "Dial"
    @AppStorage(Settings.dialVariantKey, store: AppGroup.defaults) private var variant = Scale.spans.rawValue

    var body: some View {
        Picker(title, selection: $variant) {
            ForEach(Scale.allCases) { Text($0.title).tag($0.rawValue) }
        }
        .onChange(of: variant) { WidgetCenter.shared.reloadAllTimelines() }
    }
}

struct PrecisionChoice: View {
    @AppStorage(Settings.precisionKey) private var precision = Precision.standard.rawValue

    var body: some View {
        Picker("Precision", selection: $precision) {
            ForEach(Precision.allCases) { Text($0.title).tag($0.rawValue) }
        }
    }
}
