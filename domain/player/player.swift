//
//  player.swift
//  rogue

import Foundation

public class Player {
    public var characteristics: Characteristics
    public var backpack: Backpack
    public var weapon: Weapon?
    public var isAsleep: Bool = false
    public var buffManager: BuffManager

    public init(characteristics: Characteristics, backpack: Backpack, weapon: Weapon?, buffManager: BuffManager) {
        self.characteristics = characteristics
        self.backpack = backpack
        self.weapon = weapon
        self.buffManager = buffManager
    }

    public convenience init() {
        let characteristics = Characteristics(position: Position(0, 0), maxHealth: 500, health: 500, agility: 70, strength: 70)
        let backpack = Backpack()
        let buffManager = BuffManager()
        self.init(characteristics: characteristics, backpack: backpack, weapon: nil, buffManager: buffManager)
    }

    public func useItem(category: ItemCategory, index: Int) {
        backpack.useItem(self, category: category, index: index)
    }
    
    public func pickUpItem(_ item: any ItemProtocol) -> AddingCode {
        return item.pickUp(self)
    }

    public func updateBuffs() {
        buffManager.update(player: self)
    }
}
