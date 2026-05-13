//
//  InteractAppearancePreference.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import Foundation
import SwiftUI

enum InteractAppearancePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

enum InteractAppearanceStore {
    private static let defaultPreferenceKey = "interact.appearancePreference.default"
    private static let accountPreferencePrefix = "interact.appearancePreference.account."

    static func preference(for userID: String?) -> InteractAppearancePreference {
        let defaults = UserDefaults.standard

        if let accountKey = accountKey(for: userID),
           let rawPreference = defaults.string(forKey: accountKey),
           let preference = InteractAppearancePreference(rawValue: rawPreference) {
            return preference
        }

        if let rawPreference = defaults.string(forKey: defaultPreferenceKey),
           let preference = InteractAppearancePreference(rawValue: rawPreference) {
            return preference
        }

        return .system
    }

    static func setPreference(_ preference: InteractAppearancePreference, for userID: String?) {
        let key = accountKey(for: userID) ?? defaultPreferenceKey
        UserDefaults.standard.set(preference.rawValue, forKey: key)
    }

    private static func accountKey(for userID: String?) -> String? {
        guard let userID = userID?.trimmingCharacters(in: .whitespacesAndNewlines),
              userID.isEmpty == false else {
            return nil
        }

        return accountPreferencePrefix + userID
    }
}
