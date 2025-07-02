//
//  itemTypes.swift
//  rogue

import Foundation

public struct Food: ItemProtocol {
    let foodType: FoodType

    public var type: ItemType {
        return .food(foodType)
    }

    public init(foodType: FoodType) {
        self.foodType = foodType
    }

    public func use(_ player: Player) {
        player.characteristics.health = min(player.characteristics.health + foodType.healthRestore,
                                            player.characteristics.maxHealth)
        GameEventManager.shared.notify(.eatFood(food: foodType.name, amount: foodType.healthRestore))
    }
}

public struct Scroll: ItemProtocol {
    
    let scrollType: ScrollType
    public let value: Int

    public var type: ItemType {
        return .scroll(scrollType)
    }

    public init(scrollType: ScrollType) {
        self.scrollType = scrollType
        value = Int.random(in: scrollType.effectValue)
    }
    
    public func use(_ player: Player) {
        switch scrollType {
            case .health:
                player.characteristics.maxHealth += value
                player.characteristics.health += value
            case .agility:
                player.characteristics.agility += value
            case .strength:
                player.characteristics.strength += value
        }
        GameEventManager.shared.notify(.readScroll(scroll: scrollType.name, amount: value))
    }
}

public struct Elixir: ItemProtocol {
    let elixirType: ElixirType
    public let duration: TimeInterval
    public let value: Int

    public var type: ItemType { .elixir(elixirType) }
    
    public init(elixirType: ElixirType, duration: TimeInterval) {
        self.elixirType = elixirType
        value = Int.random(in: elixirType.effectValue)
        self.duration = duration
    }

    public func use(_ player: Player) {
        player.buffManager.addBuff(for: elixirType, value: value, duration: duration)

        switch elixirType {
        case .health:
            player.characteristics.maxHealth += value
            player.characteristics.health += value
        case .agility:
            player.characteristics.agility += value
        case .strength:
            player.characteristics.strength += value
        }
        GameEventManager.shared.notify(.drinkElixir(elixir: elixirType.name, duration: Int(duration)))
    }
}

public struct Treasure: ItemProtocol {
    let treasureType: TreasureType

    public var type: ItemType { .treasure(treasureType) }

    var value: Int {
        treasureType.baseValue
    }

    public func use(_ player: Player) {
        player.backpack.totalTreasureValue += value
    }

    public func pickUp(_ player: Player) -> AddingCode {
        self.use(player)
        GameEventManager.shared.notify(.pickUpTreasure(treasure: treasureType.name, amount: value))
        return .success
    }
}

public struct Weapon: ItemProtocol {
    public let weaponType: WeaponType
    public let damage: Int
    
    public init(weaponType: WeaponType) {
        self.weaponType = weaponType
        self.damage = Int.random(in: weaponType.baseDamage)
    }
    
    public var type: ItemType { .weapon(weaponType) }

    public func use(_ player: Player) {
        if let current = player.weapon {
            _ = player.backpack.addItem(current)
        }
        player.weapon = self
        GameEventManager.shared.notify(.useWeapon(weapon: weaponType.name, damage: self.damage))
    }
}

public struct Key: ItemProtocol {
    let keyColor: Color
    
    public var type: ItemType { .key(keyColor) }
    
    public func use(_ player: Player) {
        GameEventManager.shared.notify(.openColorDoor(color: keyColor.name))
    }
}
