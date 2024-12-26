//
//  VerbProgressManager.swift
//  Quiz3o
//
//  Created by Alle D on 25/12/24.
//

import Foundation

struct VerbProgressManager {
    private static let progressKey = "VerbProgress"

    static func getProgress(for verb: String, in tense: String) -> Int {
        let allProgress = UserDefaults.standard.dictionary(forKey: progressKey) as? [String: [String: Int]] ?? [:]
        return allProgress[verb]?[tense] ?? 0
    }

    static func incrementProgress(for verb: String, in tense: String) {
        var allProgress = UserDefaults.standard.dictionary(forKey: progressKey) as? [String: [String: Int]] ?? [:]
        var verbProgress = allProgress[verb] ?? [:]
        verbProgress[tense] = (verbProgress[tense] ?? 0) + 1
        allProgress[verb] = verbProgress
        UserDefaults.standard.set(allProgress, forKey: progressKey)
    }

    static func resetProgress(for verb: String, in tense: String) {
        var allProgress = UserDefaults.standard.dictionary(forKey: progressKey) as? [String: [String: Int]] ?? [:]
        allProgress[verb]?[tense] = 0
        UserDefaults.standard.set(allProgress, forKey: progressKey)
    }

    static func resetAllProgress() {
        UserDefaults.standard.removeObject(forKey: progressKey)
    }

    static func isVerbMastered(_ verb: String, in tense: String, threshold: Int = 5) -> Bool {
        return getProgress(for: verb, in: tense) >= threshold
    }
}
