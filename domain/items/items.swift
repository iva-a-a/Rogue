//
//  items.swift
//  rogue

public enum ItemType: Hashable, Equatable {
    case food(FoodType)
    case weapon(WeaponType)
    case scroll(ScrollType)
    case elixir(ElixirType)
    case treasure(TreasureType)
    case key(Color)

    var category: ItemCategory {
        switch self {
        case .food: return .food
        case .weapon: return .weapon
        case .scroll: return .scroll
        case .elixir: return .elixir
        case .treasure: return .treasure
        case .key: return .key
        }
    }

    public var name: String {
        switch self {
        case .food(let food): return food.name
        case .weapon(let weapon): return weapon.name
        case .scroll(let scroll): return scroll.name
        case .elixir(let elixir): return elixir.name
        case .treasure(let treasure): return treasure.name
        case .key(let color): return color.name + " Key"
        }
    }
}

public enum FoodType: Hashable, Equatable {
    case apple, bread, meat

    var healthRestore: Int {
        switch self {
        case .apple: return 10
        case .bread: return 20
        case .meat: return 30
        }
    }

    var name: String {
        switch self {
        case .apple: return "Apple"
        case .bread: return "Bread"
        case .meat: return "Meat"
        }
    }
}

public enum ElixirType: Hashable, Equatable {
    case health, agility, strength

    var effectValue: Int {
        switch self {
        case .health: return 20
        case .agility: return 5
        case .strength: return 10
        }
    }

    var name: String {
        switch self {
        case .health: return "Health Elixir"
        case .agility: return "Agility Elixir"
        case .strength: return "Strength Elixir"
        }
    }
}

public enum ScrollType: Hashable, Equatable {
    case health, agility, strength

    var effectValue: Int {
        switch self {
        case .health: return Int.random(in: 5...10)
        case .agility: return Int.random(in: 3...5)
        case .strength: return Int.random(in: 5...8)
        }
    }

    var name: String {
        switch self {
        case .health: return "Health Scroll"
        case .agility: return "Agility Scroll"
        case .strength: return "Strength Scroll"
        }
    }
}

public enum WeaponType: Hashable, Equatable {
    case sword, bow, dagger, staff

    var baseDamage: Int {
        switch self {
        case .sword: return Int.random(in: 12...16)
        case .bow: return Int.random(in: 9...13)
        case .dagger: return Int.random(in: 5...9)
        case .staff: return Int.random(in: 7...11)
        }
    }

    public var name: String {
        switch self {
        case .sword: return "Sword"
        case .bow: return "Bow"
        case .dagger: return "Dagger"
        case .staff: return "Staff"
        }
    }
}

public enum TreasureType: Hashable, Equatable {
    case gold, gem, artifact

    var baseValue: Int {
        switch self {
        case .gold: return 10
        case .gem: return 50
        case .artifact: return 100
        }
    }

    var name: String {
        switch self {
        case .gold: return "Gold"
        case .gem: return "Gem"
        case .artifact: return "Artifact"
        }
    }
}

public enum AddingCode {
    case success
    case isFull
}

public protocol ItemProtocol {
    var type: ItemType { get }
    func use(_ player: Player)
    func pickUp(_ player: Player) -> AddingCode
}

extension ItemProtocol {
    public func pickUp(_ player: Player) -> AddingCode {
        let result = player.backpack.addItem(self)
        if case .isFull = result {
            GameEventManager.shared.notify(.notPickedUp)
        } else {
            GameEventManager.shared.notify(.itemPickedUp(item: type.name))
        }
        return result
    }
}
