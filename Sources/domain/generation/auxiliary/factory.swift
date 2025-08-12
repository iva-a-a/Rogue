//
//  factory.swift
//  rogue

public protocol EntityFactory {
    associatedtype EntityType
    func generate(in rooms: [Room],
                  excluding: Set<Position>,
                  player: Player,
                  level: Int,
                  difficulty: GameDifficulty) -> [Position: EntityType]
}

public struct SpawnBalancer {

    public static func calculateEntityCount(base: Int,
                                            level: Int,
                                            difficulty: GameDifficulty,
                                            player: Player,
                                            maxCount: Int = 21,
                                            modifier: Int) -> Int {
        var count = base

        count += modifier * (level / 3) * -1

        switch difficulty {
        case .easy:
            count += modifier * 2
        case .hard:
            count -= modifier * 2
        case .normal:
            break
        }
        return max(0, min(count, maxCount))
    }
}
