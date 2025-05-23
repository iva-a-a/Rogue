//
//  items.swift
//  rogue

import Foundation

public enum ItemType: Hashable, Equatable {
    case food(FoodType)
    case weapon(WeaponType)
    case scroll(ScrollType)
    case elixir(ElixirType)
    case treasure(TreasureType)

    var category: ItemCategory {
        switch self {
        case .food: return .food
        case .weapon: return .weapon
        case .scroll: return .scroll
        case .elixir: return .elixir
        case .treasure: return .treasure
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
        return player.backpack.addItem(self)
    }
}
