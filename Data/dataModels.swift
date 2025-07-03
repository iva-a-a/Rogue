// DataModels.swift

import Foundation

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

// Модель для статистики попытки прохождения
public struct GameAttempt: Codable {
    let date: Date
    let levelsCompleted: Int
    let finalScore: Int
    let wasSuccessful: Bool
    let playTime: TimeInterval
}

// Модель для таблицы лидеров
public struct LeaderboardEntry: Codable {
    let playerName: String
    let score: Int
    let levelsCompleted: Int
    let date: Date
}
