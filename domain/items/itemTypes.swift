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
        player.characteristics.health = min(player.characteristics.health + foodType.healthRestore, player.characteristics.maxHealth)
        GameEventManager.shared.notify(.eatFood(food: foodType.name, amount: foodType.healthRestore))
    }
}

public struct Scroll: ItemProtocol {
    
    let scrollType: ScrollType

    public var type: ItemType {
        return .scroll(scrollType)
    }

    public init(scrollType: ScrollType) {
        self.scrollType = scrollType
    }
    
    public func use(_ player: Player) {
        let value = scrollType.effectValue
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
    let duration: TimeInterval

    public var type: ItemType { .elixir(elixirType) }

    public func use(_ player: Player) {
        let effect = elixirType.effectValue
        player.buffManager.addBuff(for: elixirType, value: effect, duration: duration)

        switch elixirType {
        case .health:
            player.characteristics.maxHealth += effect
            player.characteristics.health += effect
        case .agility:
            player.characteristics.agility += effect
        case .strength:
            player.characteristics.strength += effect
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
    let weaponType: WeaponType

    public var type: ItemType { .weapon(weaponType) }

    public func use(_ player: Player) {
        let currentWeapon = player.weapon
        player.weapon = self
        GameEventManager.shared.notify(.useWeapon(weapon: weaponType.name, damage: weaponType.baseDamage))
        if var weapons = player.backpack.items[self.type.category],
           let index = weapons.firstIndex(where: { item in
               if case let .weapon(type) = item.type {
                   return type == self.weaponType
               }
               return false
           }) {
            weapons.remove(at: index)
            player.backpack.items[.weapon] = weapons
        }
        
        if let current = currentWeapon {
            player.backpack.items[self.type.category, default: []].append(current)
        }
    }
}
