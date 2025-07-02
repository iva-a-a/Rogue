//
//  difficultyStatistics.swift
//  rogue

public enum GameDifficulty {
    case easy, normal, hard
}


// ВРЕМЕННО, ПЕРЕДЕЛАТЬ С УЧЕТОМ СТАТИСТИКИ В DATA-МОДУЛЕ
public struct DifficultyStatistics {
    private var defeatedEnemies: Int = 0
    private var receivedDamage: Int = 0
    private var healHealth: Int = 0
    private var itemsUsed: Int = 0
    
    public mutating func addDefeatedEnemies() {
        self.defeatedEnemies += 1
    }
    
    public mutating func addReceivedDamage(_ amount: Int) {
        self.receivedDamage += amount
    }
    
    public mutating func addHealHealth(_ amount: Int) {
        self.healHealth += amount
    }
    
    public mutating func addItemsUsed() {
        self.itemsUsed += 1
    }
    // вызывать до генерации предметов и врагов при каждом норвом уровне
    public func calculateDifficulty(for player: Player, for levelNumber: Int) -> GameDifficulty {
        guard levelNumber > 1 else { return .normal }
        
        let weights = DifficultyWeights.forLevel(levelNumber)
        
        let damageRatio = Double(receivedDamage) / Double(player.characteristics.maxHealth * levelNumber)
        let healRatio = Double(healHealth) / Double(player.characteristics.maxHealth * levelNumber)
        let healthRatio = Double(player.characteristics.health) / Double(player.characteristics.maxHealth)
        let killRatio = Double(defeatedEnemies) / (0.5 * Double(levelNumber))
        let itemsRatio = Double(itemsUsed) / Double(levelNumber * 3)
        
        let strengthRatio = Double(player.characteristics.strength) / 15.0
        let agilityRatio = Double(player.characteristics.agility) / 15.0
        
        var totalScore: Double = 0
        totalScore += damageRatio * weights.damageWeight
        totalScore -= healRatio * weights.healWeight
        totalScore += (1.0 - healthRatio) * weights.healthWeight
        totalScore += killRatio * weights.killWeight
        totalScore += itemsRatio * weights.itemsWeight
        totalScore -= strengthRatio * weights.strengthWeight
        totalScore -= agilityRatio * weights.agilityWeight
        
        if let weapon = player.weapon {
            totalScore -= Double(weapon.damage) * 0.05
        }

        
        switch totalScore {
        case ..<weights.hardThreshold:
            return .hard
        case weights.hardThreshold..<weights.normalThreshold:
            return .normal
        default:
            return .easy
        }
    }

    public mutating func reset() {
        self.defeatedEnemies = 0
        self.receivedDamage = 0
        self.healHealth = 0
    }
}

private struct DifficultyWeights {
    let damageWeight: Double
    let healWeight: Double
    let healthWeight: Double
    let killWeight: Double
    let strengthWeight: Double
    let agilityWeight: Double
    let hardThreshold: Double
    let normalThreshold: Double
    let itemsWeight: Double
    
    static func forLevel(_ levelNumber: Int) -> DifficultyWeights {
        let levelScale = Double(levelNumber) * 0.1
        return DifficultyWeights(
            damageWeight: 1.0 + levelScale,
            healWeight: 0.7 - levelScale * 0.2,
            healthWeight: 15.0 + levelScale * 0.8,
            killWeight: 1.2 + levelScale * 0.3,
            strengthWeight: 2.0,
            agilityWeight: 1.5,
            hardThreshold: 12.0 + Double(levelNumber) * 1.2,
            normalThreshold: 28.0 + Double(levelNumber) * 1.5,
            itemsWeight: 0.8
        )
    }
}
