import Foundation

enum ItemType: CaseIterable {
    case food 
    case weapon
    case scroll 
    case elixir 
    case treasure
}

enum ItemRandomGenerate {
    case random 
    case none
}

protocol Item: Equatable {
    var type: ItemType { get }

    func use(_ p: Player)
    func pickUp(_ p: Player) -> AddingCode
}

extension Item {
    func pickUp(_ p: Player) -> AddingCode {
        return p.backpack.addItem(item: self)
    }
}

struct Treasure: Item {
    var type = ItemType.treasure

    var value: Int

    func use(_ p: Player) { }
    func pickUp(_ p: Player) -> AddingCode {
        p.backpack.treasure.value += self.value
        return .success
    }
}

struct Weapon: Item {
    var type = ItemType.weapon
    var strength: Int
    var name: String
    
    func use(_ p: Player) 
    {
        if let buf = p.weapon {
            _ = p.backpack.addItem(item: buf)
        }
        p.weapon = self
    }
}

struct Scroll: Item {
    var type = ItemType.scroll
    var stat: StatType
    var increase: Int
    var name: String    

    func use(_ p: Player) 
    {
        switch stat {
            case .health:
                p.maxHP += increase
                p.baseStats.health += increase
            case .agility:
                p.baseStats.agility += increase
            case .strength:
                p.baseStats.strength += increase
            default:
                break
        }
    }
}

struct Elixir: Item {
    var type = ItemType.elixir
    var duration: TimeInterval
    var stat: StatType
    var increase: Int
    var name: String    

    func use(_ p: Player) 
    {
        switch stat {
            case .health:
                p.elixirBuffs.maxHealth.append(Buf(statIncrease: increase, effectEnd: Date() + duration))
                p.maxHP += increase
                p.baseStats.health += increase
            case .agility:
                p.elixirBuffs.agility.append(Buf(statIncrease: increase, effectEnd: Date() + duration))
                p.baseStats.agility += increase
            case .strength:
                p.elixirBuffs.strength.append(Buf(statIncrease: increase, effectEnd: Date() + duration))
                p.baseStats.strength += increase
            default: 
                break
        }
    }
}

struct Food: Item {
    var type = ItemType.food
    var toRegen: Int
    var name: String

    func use(_ p: Player) {
        p.baseStats.health = (p.baseStats.health + toRegen > p.maxHP ? p.maxHP : p.baseStats.health + toRegen)
    }
}

class ItemInRoom {
    var item: any Item 
    var geometry: Object

    init(item: any Item, geometry: Object) {
        self.item = item 
        self.geometry = geometry
    }
}