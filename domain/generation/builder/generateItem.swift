//
//  generateItem.swift
//  rogue

public final class ItemEntityFactory: EntityFactory {
    public typealias EntityType = ItemProtocol
    
    public func generate(in rooms: [Room], excluding: Set<Position>, player: Player, level: Int, difficulty: GameDifficulty) -> [Position: ItemProtocol] {
        var items: [Position: ItemProtocol] = [:]
        let itemCount = SpawnBalancer.calculateEntityCount(
                base: 21, level: level, difficulty: difficulty, player: player, maxCount: 21, modifier: 1)
        let positions = GetterPositions.make(in: rooms, excluding: excluding, count: itemCount, offset: 1)
        let probabilities = Self.getProbabilities(level, difficulty)
        for i in 0..<positions.count {
            let item = Self.randomItem(probabilities: probabilities, difficulty: difficulty, player: player, level: level)
            items[positions[i]] = item
        }
        return items
    }
    
    private static func randomItem(probabilities: [ItemCategory: Double], difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        let random = Double.random(in: 0..<1)
        var runningSum = 0.0
        
        for (category, probability) in probabilities {
            runningSum += probability
            if random < runningSum {
                return createItem(of: category, for: difficulty, player: player, level: level)
            }
        }
        return createItem(of: .food, for: difficulty, player: player, level: level)
    }
    
    private static func createItem(of category: ItemCategory, for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        let factory: ItemFactory
        switch category {
            case .food: factory = FoodFactory()
            case .scroll: factory = ScrollFactory()
            case .elixir: factory = ElixirFactory()
            case .weapon: factory = WeaponFactory()
            case .treasure: factory = TreasureFactory()
        }
        return factory.createItem(for: difficulty, player: player, level: level)
    }
    
    private static func getBaseProbabilities() -> [ItemCategory: Double] {
        return [
            .food: 0.35,
            .scroll: 0.3,
            .elixir: 0.2,
            .weapon: 0.15,
        ]
    }
    
    private static func getProbabilities(_ level: Int, _ difficulty: GameDifficulty) -> [ItemCategory: Double] {
        var probabilities = getBaseProbabilities()
        adjustProbabilitiesByLevel(&probabilities, level: level)
        adjustProbabilitiesByDifficulty(&probabilities, difficulty: difficulty)
        normalizeProbabilities(&probabilities)
        return probabilities
    }
    
    private static func adjustProbabilitiesByLevel(_ probabilities: inout [ItemCategory: Double], level: Int) {
        let levelFactor = Double(level) * 0.02
        probabilities[.food]? -= levelFactor
        probabilities[.scroll]? -= levelFactor * 0.5
        probabilities[.weapon]? += levelFactor * 0.7
        probabilities[.treasure]? += levelFactor * 0.8
    }
    
    private static func adjustProbabilitiesByDifficulty(_ probabilities: inout [ItemCategory: Double], difficulty: GameDifficulty) {
        switch difficulty {
            case .easy:
                probabilities[.food]? *= 1.5
                probabilities[.elixir]? *= 1.3
                probabilities[.weapon]? *= 0.8
            case .normal: break
            case .hard:
                probabilities[.food]? *= 0.8
                probabilities[.weapon]? *= 1.2
        }
    }
    
    private static func normalizeProbabilities(_ probabilities: inout [ItemCategory: Double]) {
        let total = probabilities.values.reduce(0, +)
        for (category, _) in probabilities {
            probabilities[category]? /= total
        }
    }
}

public protocol ItemFactory {
    func createItem(for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol
}

public final class FoodFactory: ItemFactory {
    public func createItem(for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        let types: [FoodType]
        switch difficulty {
            case .easy: types = [.apple, .bread, .bread]
            case .normal: types = [.apple, .bread, .meat]
            case .hard: types = [.bread, .meat, .meat]
        }
        return Food(foodType: types.randomElement()!)
    }
}

public final class ScrollFactory: ItemFactory {
    public func createItem(for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        let scrollType: ScrollType = {
            switch level {
                case 0..<5: return .health
                case 5..<10: return [.health, .strength, .agility].randomElement()!
                default: return [.strength, .agility].randomElement()!
            }
        }()
        return Scroll(scrollType: scrollType)
    }
}

public final class ElixirFactory: ItemFactory {
    public func createItem(for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        let elixirType: ElixirType = {
            return [.health, .agility, .strength].randomElement()!
        }()
        var duration = Double.random(in: 1...3) * 30
        var effectBonus = 0
        if difficulty == .hard {
            duration *= 1.2
            effectBonus += 2
        }
        if level > 10 {
            duration *= 1.1
            effectBonus += level / 2
        }
        return Elixir(elixirType: elixirType, duration: duration)
    }
}

public final class WeaponFactory: ItemFactory {
    public func createItem(for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        let weaponType: WeaponType = {
            switch level {
                case 0..<7: return [.dagger, .staff].randomElement()!
                case 7..<15: return [.sword, .bow].randomElement()!
                default: return [.sword, .bow, .dagger, .staff].randomElement()!
            }
        }()
        return Weapon(weaponType: weaponType)
    }
}

// дописать в зависимости от уровня
public final class TreasureFactory: ItemFactory {
    public func createItem(for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        return Treasure(treasureType: .gold)
    }
}
