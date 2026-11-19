// SettingsScreen.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DialVariantChoice()
                    PrecisionChoice()
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
        }
    }
}
