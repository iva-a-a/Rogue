//
//  generateEnemy.swift
//  rogue

public final class EnemyEntityFactory: EntityFactory {

    public typealias EntityType = Enemy
    
    public func generate(in rooms: [Room],
                         excluding: Set<Position>,
                         player: Player,
                         level: Int,
                         difficulty: GameDifficulty
    ) -> [Position : EntityType] {

        var enemies: [Position: Enemy] = [:]
        let enemyCount = SpawnBalancer.calculateEntityCount(
                base: 15, level: level, difficulty: difficulty, player: player, maxCount: 10, modifier: -1)
        let positions = GetterPositions.make(in: rooms, excluding: excluding, count: enemyCount, offset: 2)
        let probabilities = Self.getProbabilities(level, difficulty)
        for i in 0..<positions.count {
            let pos = positions[i]
            let roomIndex = rooms.firstIndex(where: { $0.isInsideRoom(pos) }) ?? 0
            let enemy = Self.randomEnemy(probabilities: probabilities, difficulty: difficulty, player: player, level: level)
            enemy.indexRoom = roomIndex
            enemies[pos] = enemy
        }
        return enemies
    }

    private static func getBaseCharacteristics(type: EnemyType) -> (maxHealth: Int, health: Int,
                                                                    agility: Int, strength: Int, hostility: Int) {
        let baseStats: (maxHealth: Int, health: Int, agility: Int, strength: Int, hostility: Int)
        switch type {
            case .zombie:
                baseStats = (maxHealth: 80, health: 80, agility: 3, strength: 12, hostility: 7)
            case .vampire:
                baseStats = (maxHealth: 60, health: 60, agility: 15, strength: 10, hostility: 9)
            case .ghost:
                baseStats = (maxHealth: 40, health: 40, agility: 18, strength: 5, hostility: 6)
            case .ogre:
                baseStats = (maxHealth: 120, health: 120, agility: 2, strength: 25, hostility: 5)
            case .snakeMage:
                baseStats = (maxHealth: 50, health: 50, agility: 20, strength: 8, hostility: 8)
            case .mimic:
                baseStats = (maxHealth: 60, health: 60, agility: 25, strength: 8, hostility: 3)
        }
        return baseStats
    }
    
    static private func getModifiers(for difficulty: GameDifficulty, level: Int) -> (difficultyModifier: Double,
                                                                                     levelModifier: Double) {
        let difficultyModifier: Double
        switch difficulty {
            case .easy: difficultyModifier = 0.8
            case .normal: difficultyModifier = 1.0
            case .hard: difficultyModifier = 1.3
        }
        let levelModifier = 1.0 + Double(level) * 0.05
        return (difficultyModifier, levelModifier)
    }
    
    private static func adjustCharacteristics(
        baseStats: inout (maxHealth: Int, health: Int, agility: Int, strength: Int, hostility: Int),
        difficulty: GameDifficulty,
        level: Int
    ) {
        let (difficultyModifier, levelModifier) = getModifiers(for: difficulty, level: level)

        baseStats.maxHealth = Int(Double(baseStats.maxHealth) * difficultyModifier * levelModifier)
        baseStats.health = baseStats.maxHealth
        baseStats.strength = Int(Double(baseStats.strength) * difficultyModifier * levelModifier)
        baseStats.agility = Int(Double(baseStats.agility) * difficultyModifier)
    }

    private static func getBaseProbabilities() -> [EnemyType: Double] {
        return [
            .zombie: 0.4,
            .vampire: 0.27,
            .ghost: 0.15,
            .ogre: 0.1,
            .snakeMage: 0.05,
            .mimic: 0.03
        ]
    }
    
    private static func getProbabilities(_ level: Int, _ difficulty: GameDifficulty) -> [EnemyType: Double] {
        var probabilities = getBaseProbabilities()
        adjustProbabilitiesByLevel(&probabilities, level: level)
        adjustProbabilitiesByDifficulty(&probabilities, difficulty: difficulty)
        normalizeProbabilities(&probabilities)
        return probabilities
    }
    
    private static func adjustProbabilitiesByLevel(_ probabilities: inout [EnemyType: Double], level: Int) {
        let levelFactor = Double(level) * 0.03
        probabilities[.zombie]? -= levelFactor
        probabilities[.vampire]? += levelFactor * 0.5
        probabilities[.ghost]? += levelFactor * 0.6
        probabilities[.ogre]? += levelFactor * 0.7
        probabilities[.snakeMage]? += levelFactor * 0.8
        probabilities[.mimic]? += levelFactor * 0.3
    }
    
    private static func adjustProbabilitiesByDifficulty(_ probabilities: inout [EnemyType: Double],
                                                        difficulty: GameDifficulty) {
        switch difficulty {
            case .easy:
                probabilities[.zombie]? *= 1.3
                probabilities[.ogre]? *= 0.5
                probabilities[.snakeMage]? *= 0.3
                probabilities[.mimic]? *= 0.3
            case .normal: break
            case .hard:
                probabilities[.zombie]? *= 0.7
                probabilities[.ogre]? *= 1.5
                probabilities[.snakeMage]? *= 2.0
                probabilities[.mimic]? *= 1.5
        }
    }
    
    private static func normalizeProbabilities(_ probabilities: inout [EnemyType: Double]) {
        let total = probabilities.values.reduce(0, +)
        for (type, _) in probabilities {
            probabilities[type]? /= total
        }
    }
    
    private static func randomEnemy(probabilities: [EnemyType: Double],
                                    difficulty: GameDifficulty,
                                    player: Player,
                                    level: Int
    ) -> Enemy {
        let random = Double.random(in: 0..<1)
        var runningSum = 0.0
        
        for (type, probability) in probabilities {
            runningSum += probability
            if random < runningSum {
                return createEnemy(of: type, for: difficulty, player: player, level: level)
            }
        }
        return createEnemy(of: .zombie, for: difficulty, player: player, level: level)
    }

    private static func createEnemy(of type: EnemyType, for difficulty: GameDifficulty, player: Player, level: Int) -> Enemy {
        var baseStats = getBaseCharacteristics(type: type)
        adjustCharacteristics(baseStats: &baseStats, difficulty: difficulty, level: level)
        
        let characteristics = Characteristics(
            position: Position(0, 0),
            maxHealth: baseStats.maxHealth,
            health: baseStats.health,
            agility: baseStats.agility,
            strength: baseStats.strength
        )
        
        switch type {
            case .zombie: return Zombie(characteristics: characteristics, hostility: baseStats.hostility)
            case .vampire: return Vampire(characteristics: characteristics, hostility: baseStats.hostility)
            case .ghost: return Ghost(characteristics: characteristics, hostility: baseStats.hostility)
            case .ogre: return Ogre(characteristics: characteristics, hostility: baseStats.hostility)
            case .snakeMage: return SnakeMage(characteristics: characteristics, hostility: baseStats.hostility)
            case .mimic: return Mimic(characteristics: characteristics, hostility: baseStats.hostility)
        }
    }
}
