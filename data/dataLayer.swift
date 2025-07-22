//
//  dataLayer.swift
//  rogue

import Foundation

public class DataLayer {
    private let saveFileName = "game_save.json"
    private let statsFileName = "game_stats.json"
    
    public init() { }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    
    public func saveGameAttempt(_ attempt: GameAttempt) throws {
        var allAttempts = loadAllGameAttempts()
        allAttempts.append(attempt)

        let encoder = JSONEncoder()
        let data = try encoder.encode(allAttempts)

        let statsURL = documentsDirectory.appendingPathComponent(statsFileName)
        try data.write(to: statsURL)
    }

    private func loadAllGameAttempts() -> [GameAttempt] {
        let statsURL = documentsDirectory.appendingPathComponent(statsFileName)

        guard FileManager.default.fileExists(atPath: statsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: statsURL)
            let decoder = JSONDecoder()
            return try decoder.decode([GameAttempt].self, from: data)
        } catch {
            return []
        }
    }
    
    public func getSortedGameAttempts() -> [GameAttempt] {
        let attempts = loadAllGameAttempts()
        return attempts.sorted { $0.totalTreasure > $1.totalTreasure }
    }
    
    public func saveLevelDTO(_ dto: LevelDTO) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(dto)

        let saveURL = documentsDirectory.appendingPathComponent(saveFileName)
        try data.write(to: saveURL)
    }

    public func loadLevelDTO() throws -> LevelDTO? {
        let saveURL = documentsDirectory.appendingPathComponent(saveFileName)

        guard FileManager.default.fileExists(atPath: saveURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: saveURL)
        let decoder = JSONDecoder()
        return try decoder.decode(LevelDTO.self, from: data)
    }

    func deleteSave() throws {
        let saveURL = documentsDirectory.appendingPathComponent(saveFileName)
        if FileManager.default.fileExists(atPath: saveURL.path) {
            try FileManager.default.removeItem(at: saveURL)
        }
    }
}
