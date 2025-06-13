//
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
        let characteristics = Characteristics(position: Position(0, 0), maxHealth: 100, health: 100, agility: 10, strength: 8)
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
    
    @discardableResult
    public func dropWeapon() -> Weapon? {
        defer { self.weapon = nil }
        return self.weapon
    }

    public func updateBuffs() {
        buffManager.update(player: self)
    }
    
    public func attack(_ target: Enemy) -> AttackResult {
        return CombatSystem.performAttack(from: self, to: target)
    }
    
    public func move(to position: Position, in gameMap: GameMap) {
        if !gameMap.isWalkable(position) {
            return
        }
        gameMap.rewrite(from: characteristics.position, to: position)
        characteristics.position = position
    }
}

extension Player: CombatUnit {
    public var agility: Int { characteristics.agility }
    public var strength: Int { characteristics.strength }

    public var weaponDamage: Int? {
        weapon?.weaponType.baseDamage
    }

    public func receiveDamage(_ damage: Int) {
        characteristics.health -= damage
        characteristics.health = max(0, characteristics.health)
    }

    public var isDead: Bool {
        characteristics.health <= 0
    }
}

// MARK: - Save & Load Support

extension Player {
    
    // Сохранение состояния игрока в PlayerSaveData
    public func toSaveData(currentLevel: Int, score: Int) -> PlayerSaveData {
        let inventoryData = backpack.getAllItems().map { item in
            InventoryItemSaveData(category: item.category, specificType: item.uniqueIdentifier)
        }
        
        return PlayerSaveData(
            characteristics: characteristics,
            inventory: inventoryData,
            score: score,
            currentLevel: currentLevel
        )
    }
    
    // Инициализация игрока из PlayerSaveData
    public convenience init(from saveData: PlayerSaveData) {
        let characteristics = saveData.characteristics
        let backpack = Backpack()
        
        // Восстановление предметов инвентаря из сохранённых данных
        for itemData in saveData.inventory {
            if let item = ItemFactory.createItem(category: itemData.category, specificType: itemData.specificType) {
                backpack.addItem(item)
            }
        }
        
        let buffManager = BuffManager()
        self.init(characteristics: characteristics, backpack: backpack, weapon: nil, buffManager: buffManager)
    }
}
