// SettingsStore.swift
import Foundation
import Combine

final class SettingsStore: ObservableObject {
    @Published var baselinePigmentation: Int? {
        didSet { save() }
    }
    @Published var baselineRedness: Int? {
        didSet { save() }
    }
    @Published var pigScale: Double {
        didSet { save() }
    }
    @Published var redScale: Double {
        didSet { save() }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let baselinePig = "baselinePigmentation"
        static let baselineRed = "baselineRedness"
        static let pigScale = "pigScale"
        static let redScale = "redScale"
    }

    init() {
        baselinePigmentation = defaults.object(forKey: Keys.baselinePig) as? Int
        baselineRedness = defaults.object(forKey: Keys.baselineRed) as? Int

        if let s = defaults.object(forKey: Keys.pigScale) as? Double {
            pigScale = s
        } else {
            pigScale = 1.0   // default pigmentation scaling
        }

        if let s = defaults.object(forKey: Keys.redScale) as? Double {
            redScale = s
        } else {
            redScale = 1.0   // default redness scaling (more sensitive)
        }
    }

    func setBaselineIfNeeded(pig: Int, red: Int) {
        var changed = false
        if baselinePigmentation == nil {
            baselinePigmentation = pig
            changed = true
        }
        if baselineRedness == nil {
            baselineRedness = red
            changed = true
        }
        if changed { save() }
    }

    private func save() {
        if let pig = baselinePigmentation {
            defaults.set(pig, forKey: Keys.baselinePig)
        }
        if let red = baselineRedness {
            defaults.set(red, forKey: Keys.baselineRed)
        }
        defaults.set(pigScale, forKey: Keys.pigScale)
        defaults.set(redScale, forKey: Keys.redScale)
    }
    
    func resetAll() {
        baselinePigmentation = nil
        baselineRedness = nil

        // Optional: reset sensitivity sliders to defaults
        pigScale = 1.0
        redScale = 1.0
    }
}
