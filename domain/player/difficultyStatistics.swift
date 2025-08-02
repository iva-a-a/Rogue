//
//  difficultyStatistics.swift
//  rogue

public struct DifficultyCalculator {

    public static func getDifficulty(for player: Player, for levelNumber: Int, for previosDifficulty: GameDifficulty) -> GameDifficulty {
        guard levelNumber > 1 else { return .easy }

        let stats = GameStatsLevel.shared.currentStats()
        let playerPower = calculatePlayerPower(player, levelNumber: levelNumber)
        let expected = expectedEnemies(for: levelNumber)
        let weights = DifficultyWeights.forLevel(levelNumber)

        let healthRatio = Double(player.characteristics.health) / Double(player.characteristics.maxHealth)
        let healthLoss = 1.0 - healthRatio

        let damageRatio = Double(stats.receivedDamage) / Double(100 + player.characteristics.maxHealth * levelNumber)
        let healRatio = Double(stats.healHealth) / Double(50 + player.characteristics.maxHealth * levelNumber)
        let killRatio = Double(stats.defeatedEnemies) / Double(expected)

        let criticalHealthPenalty: Double = healthRatio < 0.25 ? (1.0 - healthRatio) * 2.0 : 0.0

        let performanceScore =
            (healthLoss * weights.healthWeight) +
            (damageRatio * weights.damageWeight) +
            (healRatio * weights.healWeight) -
            (killRatio * weights.killWeight) -
            (playerPower * weights.powerWeight) +
            criticalHealthPenalty

        if performanceScore < 0 {
            return harderDifficulty(previous: previosDifficulty)
        } else if performanceScore > 1.5 {
            return easierDifficulty(previous: previosDifficulty)
        } else {
            return previosDifficulty
        }
    }

    private static func harderDifficulty(previous: GameDifficulty) -> GameDifficulty {
        switch previous {
            case .easy: return .normal
            case .normal: return .hard
            case .hard: return .hard
        }
    }

    private static func easierDifficulty(previous: GameDifficulty) -> GameDifficulty {
        switch previous {
            case .hard: return .normal
            case .normal: return .easy
            case .easy: return .easy
        }
    }

    private static func calculatePlayerPower(_ player: Player, levelNumber: Int) -> Double {
        let basePower = (Double(player.characteristics.strength) / 30.0 +
                         Double(player.characteristics.agility) / 25.0) / 2.0

        let weaponPower = player.weapon != nil ? 0.2 : 0

        let levelFactor = 1.0 - Double(min(levelNumber, 21)) / 30.0

        return (basePower + weaponPower) * levelFactor
    }

    private static func expectedEnemies(for level: Int) -> Int {
        return 5 + level * 3
    }
}

private struct DifficultyWeights {
    let damageWeight: Double
    let healWeight: Double
    let healthWeight: Double
    let killWeight: Double
    let powerWeight: Double

    static func forLevel(_ levelNumber: Int) -> DifficultyWeights {
        let levelFactor = Double(levelNumber) * 0.1

        return DifficultyWeights(
            damageWeight: 1.1 + levelFactor,
            healWeight: 0.5,
            healthWeight: 2.0 + levelFactor,
            killWeight: 1.0 + levelFactor,
            powerWeight: 1.8 - levelFactor * 0.05
        )
    }
}
