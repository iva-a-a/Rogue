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
    
    public init(date: Date, levelsCompleted: Int, totalTreasure: Int,
                finalScore: Int, wasSuccessful: Bool, playTime: TimeInterval,
                enemiesDefeated: Int, foodConsumed: Int, elixirsDrunk: Int,
                scrollsRead: Int, attacksMade: Int, attacksMissed: Int, missFromAttack: Int, hitFromAttack: Int, tilesExplored: Int) {
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

public struct LevelDTO: Codable {
    public let rooms: [RoomDTO]
    public let corridors: [CorridorDTO]
    public let exitPosition: PositionDTO
    public let player: PlayerDTO
    public let enemies: [EnemyDTO]
    public let items: [PositionDTO: ItemDTO]
    public let levelNumber: Int
    public let gameMap: GameMapDTO
    public let exploredPositions: Set<PositionDTO>
    
    public init(rooms: [RoomDTO],
                corridors: [CorridorDTO],
                exitPosition: PositionDTO,
                player: PlayerDTO,
                enemies: [EnemyDTO],
                items: [PositionDTO: ItemDTO],
                levelNumber: Int,
                gameMap: GameMapDTO,
                exploredPositions: Set<PositionDTO>) {
        self.rooms = rooms
        self.corridors = corridors
        self.exitPosition = exitPosition
        self.player = player
        self.enemies = enemies
        self.items = items
        self.levelNumber = levelNumber
        self.gameMap = gameMap
        self.exploredPositions = exploredPositions
    }
}

public struct RoomDTO: Codable {
    public let topRight: PositionDTO
    public let lowLeft: PositionDTO
    public let doors: [DoorDTO]
    
    public init(topRight: PositionDTO, lowLeft: PositionDTO, doors: [DoorDTO]) {
        self.topRight = topRight
        self.lowLeft = lowLeft
        self.doors = doors
    }
}

public struct CorridorDTO: Codable {
    public let route: [PositionDTO]
    
    public init(route: [PositionDTO]) {
        self.route = route
    }
}

public struct PositionDTO: Codable, Hashable {
    public let x: Int
    public let y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public struct DoorDTO: Codable {
    public let position: PositionDTO
    public let direction: DirectionDTO
    public let color: ColorDTO
    public let isUnlocked: Bool
    
    public init(position: PositionDTO, direction: DirectionDTO, color: ColorDTO, isUnlocked: Bool) {
        self.position = position
        self.direction = direction
        self.color = color
        self.isUnlocked = isUnlocked
    }
}

public enum DirectionDTO: String, Codable, CaseIterable {
    case up, down, left, right
}

public enum ColorDTO: String, Codable {
    case red, green, blue, none
}

public struct PlayerDTO: Codable {
    public let characteristics: CharacteristicsDTO
    public let backpack: BackpackDTO
    public let weapon: ItemDTO?
    public let buffs: BuffsDTO
    public let isAsleep: Bool
    
    public init(characteristics: CharacteristicsDTO, backpack: BackpackDTO, weapon: ItemDTO? = nil, buffs: BuffsDTO, isAsleep: Bool) {
        self.characteristics = characteristics
        self.backpack = backpack
        self.weapon = weapon
        self.buffs = buffs
        self.isAsleep = isAsleep
    }
}

public struct CharacteristicsDTO: Codable {
    public var position: PositionDTO
    public var maxHealth: Int
    public var health: Int
    public var agility: Int
    public var strength: Int
    
    public init(position: PositionDTO, maxHealth: Int, health: Int, agility: Int, strength: Int) {
        self.position = position
        self.maxHealth = maxHealth
        self.health = health
        self.agility = agility
        self.strength = strength
    }
}

public struct BackpackDTO: Codable {
    public var items: [ItemCategoryDTO: [ItemDTO]]
    public var totalTreasureValue: Int
    
    public init(items: [ItemCategoryDTO : [ItemDTO]], totalTreasureValue: Int) {
        self.items = items
        self.totalTreasureValue = totalTreasureValue
    }
}

public struct ItemDTO: Codable {
    public let type: ItemTypeDTO
    public let value: Int?
    public let duration: TimeInterval?
    public let color: ColorDTO?
    public let damage: Int?
    
    public init(type: ItemTypeDTO, value: Int? = nil, duration: TimeInterval? = nil, color: ColorDTO? = nil, damage: Int? = nil) {
        self.type = type
        self.value = value
        self.duration = duration
        self.color = color
        self.damage = damage
    }
    
    public init() {
        self.type = .food(.apple)
        self.value = nil
        self.duration = nil
        self.color = nil
        self.damage = nil
    }
}

public enum ItemTypeDTO: Codable, Hashable {
    case food(FoodTypeDTO)
    case weapon(WeaponTypeDTO)
    case scroll(ScrollTypeDTO)
    case elixir(ElixirTypeDTO)
    case treasure(TreasureTypeDTO)
    case key(ColorDTO)
}

public enum ItemCategoryDTO: String, Codable, Hashable {
    case food
    case weapon
    case scroll
    case elixir
    case treasure
    case key
}

public enum FoodTypeDTO: String, Codable, Hashable {
    case apple, bread, meat
}

public enum ElixirTypeDTO: String, Codable, Hashable {
    case health, agility, strength
}

public enum ScrollTypeDTO: String, Codable, Hashable {
    case health, agility, strength
}

public enum WeaponTypeDTO: String, Codable, Hashable {
    case sword, bow, dagger, staff
}

public enum TreasureTypeDTO: String, Codable, Hashable {
    case gold, gem, artifact
}

public struct BuffsDTO: Codable {
    public let health: [ElixirBufDTO]
    public let agility: [ElixirBufDTO]
    public let strength: [ElixirBufDTO]
    
    public init(health: [ElixirBufDTO], agility: [ElixirBufDTO], strength: [ElixirBufDTO]) {
        self.health = health
        self.agility = agility
        self.strength = strength
    }
}

public struct ElixirBufDTO: Codable {
    public let statIncrease: Int
    public let effectEnd: TimeInterval
    
    public init(statIncrease: Int, effectEnd: TimeInterval) {
        self.statIncrease = statIncrease
        self.effectEnd = effectEnd
    }
}

public struct EnemyDTO: Codable {
    public let type: EnemyTypeDTO
    public let characteristics: CharacteristicsDTO
    public let hostility: Int
    public let isVisible: Bool
    public let indexRoom: Int
    public let isResting: Bool?
    public let wasFirstAttacked: Bool?
    public let depictsItem: Bool?
    public let disguisedItemType: ItemTypeDTO?

    public init(type: EnemyTypeDTO,
                characteristics: CharacteristicsDTO,
                hostility: Int,
                isVisible: Bool,
                indexRoom: Int,
                isResting: Bool? = nil,
                wasFirstAttacked: Bool? = nil,
                depictsItem: Bool? = nil,
                disguisedItemType: ItemTypeDTO? = nil) {
        self.type = type
        self.characteristics = characteristics
        self.hostility = hostility
        self.isVisible = isVisible
        self.indexRoom = indexRoom
        self.isResting = isResting
        self.wasFirstAttacked = wasFirstAttacked
        self.depictsItem = depictsItem
        self.disguisedItemType = disguisedItemType
    }
}

public enum EnemyTypeDTO: String, Codable {
    case zombie, vampire, ghost, ogre, snakeMage, mimic
}

public struct GameMapDTO: Codable {
    public let walkablePositions: Set<PositionDTO>
    public let visibleTiles: Set<PositionDTO>
    public let seenTiles: Set<PositionDTO>
    
    public init(walkablePositions: Set<PositionDTO>,
                visibleTiles: Set<PositionDTO>,
                seenTiles: Set<PositionDTO>) {
        self.walkablePositions = walkablePositions
        self.visibleTiles = visibleTiles
        self.seenTiles = seenTiles
    }
}
