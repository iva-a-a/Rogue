//
//  dataModels.swift
//  rogue

import Foundation

// Модель для статистики попытки прохождения
public struct GameAttempt: Codable {
    public let date: Date
    public var levelsCompleted: Int
    public var totalTreasure: Int // количество найденных сокровищ
    public var finalScore: Int // для стоимости сокровища
    public var wasSuccessful: Bool
    public var playTime: TimeInterval
    public var enemiesDefeated: Int
    public var foodConsumed: Int
    public var elixirsDrunk: Int
    public var scrollsRead: Int
    public var attacksMade: Int // количество сделанных игроком ударов
    public var attacksMissed: Int // количество ударов, которые сделал игрок и промахнулся
    public var missFromAttack: Int // количество промахов по игроку
    public var hitFromAttack: Int  // количество ударов по игроку
    public var tilesExplored: Int
    //public let namePlayer: String
    
    public init(date: Date, levelsCompleted: Int, totalTreasure: Int, finalScore: Int, wasSuccessful: Bool, playTime: TimeInterval, enemiesDefeated: Int, foodConsumed: Int, elixirsDrunk: Int, scrollsRead: Int, attacksMade: Int, attacksMissed: Int, missFromAttack: Int, hitFromAttack: Int, tilesExplored: Int) {
        self.date = date
        self.levelsCompleted = levelsCompleted
        self.totalTreasure = totalTreasure
        self.finalScore = finalScore
        self.wasSuccessful = wasSuccessful
        self.playTime = playTime
        self.enemiesDefeated = enemiesDefeated
        self.foodConsumed = foodConsumed
        self.elixirsDrunk = elixirsDrunk
        self.scrollsRead = scrollsRead
        self.attacksMade = attacksMade
        self.attacksMissed = attacksMissed
        self.missFromAttack = missFromAttack
        self.hitFromAttack = hitFromAttack
        self.tilesExplored = tilesExplored
    }
}

public struct Leaderboard: Codable {
    let attempts: [GameAttempt]
}


/*
// Модель для сохранения состояния игрока
public struct PlayerSaveData: Codable {
    let characteristics: Characteristics
    let inventory: [InventoryItemSaveData] // Используем InventoryItemSaveData для конкретных предметов
    let score: Int
    let currentLevel: Int
}

// Модель для элемента инвентаря игрока
public struct InventoryItemSaveData: Codable {
    let category: ItemCategory
    let specificType: String // Уникальный идентификатор для каждого типа предмета
}

// Модель для сохранения состояния врага
public struct EnemySaveData: Codable {
    let type: EnemyType
    let characteristics: Characteristics
    let position: Position
    let indexRoom: Int
    let isVisible: Bool
}

// Модель для сохранения состояния предмета на уровне
public struct ItemSaveData: Codable {
    let type: ItemCategory
    let position: Position
}

// Модель для сохранения полного состояния уровня
public struct LevelSaveData: Codable {
    let levelNumber: Int
    let playerData: PlayerSaveData
    let enemies: [EnemySaveData]
    let items: [ItemSaveData]
    let exitPosition: Position
}

// Модель для таблицы лидеров
public struct LeaderboardEntry: Codable {
    let playerName: String
    let score: Int
    let levelsCompleted: Int
    let date: Date
}
*/
