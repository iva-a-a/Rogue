//
//  dataLayer.swift
//  rogue

import Foundation

public class DataLayer {
  //  private let saveFileName = "game_save.json"
    private let statsFileName = "game_stats.json"
   // private let leaderboardFileName = "leaderboard.json"
    
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

    func loadAllGameAttempts() -> [GameAttempt] {
        let statsURL = documentsDirectory.appendingPathComponent(statsFileName)

        guard FileManager.default.fileExists(atPath: statsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: statsURL)
            let decoder = JSONDecoder()
            return try decoder.decode([GameAttempt].self, from: data)
        } catch {
            print("Error loading game attempts: \(error)")
            return []
        }
    }

    // MARK: - Сохранение игры
/*
    func saveGame(level: Level, player: Player) throws {
        let levelData = prepareLevelData(level: level, player: player)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(levelData)

        let saveURL = documentsDirectory.appendingPathComponent(saveFileName)
        try data.write(to: saveURL)
    }

    private func prepareLevelData(level: Level, player: Player) -> LevelSaveData {
        let enemyData = level.enemies.map { enemy in
            EnemySaveData(
                type: enemy.type,
                characteristics: enemy.characteristics,
                position: enemy.characteristics.position,
                indexRoom: enemy.indexRoom,
                isVisible: enemy.isVisible
            )
        }

        let itemData = level.items.map { item in
            ItemSaveData(
                type: item.value.category,
                position: item.key
            )
        }

        let inventoryData = player.backpack.getAllItems().map { item in
            InventoryItemSaveData(
                category: item.category,
                specificType: item.uniqueID
            )
        }

        return LevelSaveData(
            levelNumber: level.levelNumber,
            playerData: PlayerSaveData(
                characteristics: player.characteristics,
                inventory: inventoryData,
                score: player.score,
                currentLevel: level.levelNumber
            ),
            enemies: enemyData,
            items: itemData,
            exitPosition: level.exitPosition
        )
    }

    // MARK: - Загрузка игры

    func loadGame() throws -> (level: Level, player: Player)? {
        let saveURL = documentsDirectory.appendingPathComponent(saveFileName)

        guard FileManager.default.fileExists(atPath: saveURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: saveURL)
        let decoder = JSONDecoder()
        let savedData = try decoder.decode(LevelSaveData.self, from: data)

        return try restoreGame(from: savedData)
    }

    private func restoreGame(from savedData: LevelSaveData) throws -> (Level, Player) {
        let player = Player()
        player.characteristics = savedData.playerData.characteristics
        player.score = savedData.playerData.score

        let restoredItems = savedData.playerData.inventory.map { itemData in
            ItemFactory.createItem(category: itemData.category, uniqueID: itemData.specificType)
        }
        player.backpack.setItems(restoredItems)

        let level = LevelBuilder.buildLevel(levelNumber: savedData.levelNumber)

        for enemyData in savedData.enemies {
            let enemy = createEnemy(from: enemyData)
            level.enemies.append(enemy)
            level.gameMap.removePosition(enemyData.position)
        }

        for itemData in savedData.items {
            let item = createItem(from: itemData)
            level.items[itemData.position] = item
            level.gameMap.removePosition(itemData.position)
        }

        level.exitPosition = savedData.exitPosition

        return (level, player)
    }

    private func createEnemy(from data: EnemySaveData) -> Enemy {
        let characteristics = data.characteristics
        let hostility = 50

        switch data.type {
        case .zombie:
            return Zombie(characteristics: characteristics, hostility: hostility)
        case .vampire:
            return Vampire(characteristics: characteristics, hostility: hostility)
        case .ghost:
            return Ghost(characteristics: characteristics, hostility: hostility)
        case .ogre:
            return Ogre(characteristics: characteristics, hostility: hostility)
        case .snakeMage:
            return SnakeMage(characteristics: characteristics, hostility: hostility)
        case .mimic:
            return Mimic(characteristics: characteristics, hostility: hostility)
        }
    }

    private func createItem(from data: ItemSaveData) -> ItemProtocol {
        return ItemFactory.createItem(category: data.type, uniqueID: "default")
    }

    // MARK: - Статистика и таблица лидеров

    func updateLeaderboard(with entry: LeaderboardEntry) throws {
        var leaderboard = loadLeaderboard()
        leaderboard.append(entry)
        leaderboard.sort { $0.score > $1.score }

        if leaderboard.count > 10 {
            leaderboard = Array(leaderboard.prefix(10))
        }

        let encoder = JSONEncoder()
        let data = try encoder.encode(leaderboard)

        let leaderboardURL = documentsDirectory.appendingPathComponent(leaderboardFileName)
        try data.write(to: leaderboardURL)
    }

    func loadLeaderboard() -> [LeaderboardEntry] {
        let leaderboardURL = documentsDirectory.appendingPathComponent(leaderboardFileName)

        guard FileManager.default.fileExists(atPath: leaderboardURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: leaderboardURL)
            let decoder = JSONDecoder()
            return try decoder.decode([LeaderboardEntry].self, from: data)
        } catch {
            print("Error loading leaderboard: \(error)")
            return []
        }
    }

    // MARK: - Удаление сохранений

    func deleteSave() throws {
        let saveURL = documentsDirectory.appendingPathComponent(saveFileName)
        if FileManager.default.fileExists(atPath: saveURL.path) {
            try FileManager.default.removeItem(at: saveURL)
        }
    }
 */
}
