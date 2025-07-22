//
//  mapperLeaderboard.swift
//  rogue

import presentation
import data

public struct MapperLeaderboard {

    public static func toViewModel(_ attemps: [GameAttempt]) -> [LeaderboardView] {
        return attemps.map {
            LeaderboardView(treasure: $0.totalTreasure, levelsCompleted: $0.levelsCompleted,
                            enemiesDefeated: $0.enemiesDefeated, food: $0.foodConsumed,
                            elixirs: $0.elixirsDrunk, scrolls: $0.scrollsRead,
                            attacks: $0.attacksMade, missed: $0.attacksMissed,
                            tiles: $0.tilesExplored)
        }
    }
}
