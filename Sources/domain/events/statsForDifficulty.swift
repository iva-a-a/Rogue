//
//  statsForDifficulty.swift
//  rogue

public enum GameDifficulty {
    case easy, normal, hard
}

extension GameDifficulty {
    public var stringValue: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
}

public struct StatisticsLevel {
    public var defeatedEnemies: Int
    public var receivedDamage: Int
    public var healHealth: Int
    public var itemsUsed: Int

    public init() {
        self.defeatedEnemies = 0
        self.receivedDamage = 0
        self.healHealth = 0
        self.itemsUsed = 0
    }
}

public final class GameStatsLevel: GameEventObserver  {
    private var stats = StatisticsLevel()
    public static let shared = GameStatsLevel()

    private init() {
        GameEventManager.shared.addObserver(self)
    }

    deinit {
        GameEventManager.shared.removeObserver(self)
    }

    public func didReceiveEvent(event: GameEvent) {
        switch event {
        case .enemyDefeated:
            stats.defeatedEnemies += 1
        case .enemyHit(_, let damage):
            stats.receivedDamage += damage
        case .eatFood(_, let amount):
            stats.healHealth += amount
            stats.itemsUsed += 1
        case .drinkElixir(_, _), .useWeapon(_, _), .readScroll(_, _):
            stats.itemsUsed += 1
        case .levelGenerated:
            reset()
        default: break
        }
    }

    private func reset() {
        self.stats = StatisticsLevel()
    }

    public func currentStats() -> StatisticsLevel {
        return stats
    }
}

