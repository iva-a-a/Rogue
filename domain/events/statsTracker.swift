//
//  statsTracker.swift
//  rogue

import Foundation
import data

public final class GameStatsTracker: GameEventObserver {
    private var attempt: GameAttempt
    private let dataLayer = DataLayer()

    public init() {
        self.attempt = GameAttempt(date: Date(),
                                   levelsCompleted: 0,
                                   totalTreasure: 0,
                                   finalScore: 0,
                                   wasSuccessful: false,
                                   playTime: 0,
                                   enemiesDefeated: 0,
                                   foodConsumed: 0,
                                   elixirsDrunk: 0,
                                   scrollsRead: 0,
                                   attacksMade: 0,
                                   attacksMissed: 0,
                                   missFromAttack: 0,
                                   hitFromAttack: 0,
                                   tilesExplored: 0)
        GameEventManager.shared.addObserver(self)
    }

    deinit {
        GameEventManager.shared.removeObserver(self)
    }

    public func didReceiveEvent(event: GameEvent) {
        switch event {
        case .playerMissed:
            attempt.attacksMade += 1
            attempt.attacksMissed += 1
        case .playerHit: attempt.attacksMade += 1
        case .enemyMissed: attempt.missFromAttack += 1
        case .enemyHit: attempt.hitFromAttack += 1
        case .enemyDefeated: attempt.enemiesDefeated += 1
        case .playerMoved: attempt.tilesExplored += 1
        case .eatFood: attempt.foodConsumed += 1
        case .drinkElixir: attempt.elixirsDrunk += 1
        case .readScroll: attempt.scrollsRead += 1
        case .pickUpTreasure(_, let amount):
            attempt.totalTreasure += 1
            attempt.finalScore += amount
        case .levelComplete(let number): attempt.levelsCompleted = max(attempt.levelsCompleted, number)
        case .gameOver: save()
        case .gameWon:
            attempt.wasSuccessful = true
            attempt.levelsCompleted += 1
            save()
        default: break
        }
    }

    private func save() {
        attempt = GameAttempt(date: attempt.date,
                              levelsCompleted: attempt.levelsCompleted,
                              totalTreasure: attempt.totalTreasure,
                              finalScore: attempt.finalScore,
                              wasSuccessful: attempt.wasSuccessful,
                              playTime: Date().timeIntervalSince(attempt.date),
                              enemiesDefeated: attempt.enemiesDefeated,
                              foodConsumed: attempt.foodConsumed,
                              elixirsDrunk: attempt.elixirsDrunk,
                              scrollsRead: attempt.scrollsRead,
                              attacksMade: attempt.attacksMade,
                              attacksMissed: attempt.attacksMissed,
                              missFromAttack: attempt.missFromAttack,
                              hitFromAttack: attempt.hitFromAttack,
                              tilesExplored: attempt.tilesExplored)

        do {
            try dataLayer.saveGameAttempt(attempt)
            GameLogger.shared.didReceiveEvent(event: .operationSuccess(message: "Game statistics saved successfully!"))
        } catch let error {
            GameLogger.shared.didReceiveEvent(event: .operationFailed(error: error.localizedDescription))
        }
    }
}
