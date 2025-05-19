import Foundation

struct Character {
    var coords: Position 
    var health: Int
    var agility: Int 
    var strength: Int
}

class Player {
    var baseStats: Character 
    var backpack: Backpack

    var maxHP: Int
    var weapon: Weapon?
    var elixirBuffs: Buffs

    init(baseStats: Character, backpack: Backpack, maxHP: Int, weapon: Weapon?, elixirBuffs: Buffs) {
        self.baseStats = baseStats
        self.backpack = backpack
        self.maxHP = maxHP 
        self.weapon = weapon
        self.elixirBuffs = elixirBuffs
    }

    convenience init() {
        let baseStats = Character(coords: Position(0, 0), health: 500, agility: 70, strength: 70)
        let backpack = Backpack()
        let maxHP = 500 
        let elixirBuffs = Buffs(maxHealth: [], agility: [], strength: [])
        self.init(baseStats: baseStats, backpack: backpack, maxHP: maxHP, weapon: nil, elixirBuffs: elixirBuffs)
    }

    func useItem(index: Int, type: ItemType) {
        backpack.useItem(self, type: type, index: index)
    }

    func addItem(item: any Item) -> AddingCode {
        backpack.addItem(item: item)
    }

    func checkTempEffectEnd() {
        elixirBuffs.maxHealth = elixirBuffs.maxHealth.filter { buf in
            if buf.effectEnd <= Date() {
                maxHP -= buf.statIncrease 
                baseStats.health = (baseStats.health - buf.statIncrease <= 0 ? 1 : baseStats.health - buf.statIncrease)
                return false
            }
            return true
        }
        elixirBuffs.agility = elixirBuffs.agility.filter { buf in
            if buf.effectEnd <= Date() {
                baseStats.agility -= buf.statIncrease
                return false
            }
            return true
        }
        elixirBuffs.strength = elixirBuffs.strength.filter { buf in
            if buf.effectEnd <= Date() {
                baseStats.strength -= buf.statIncrease
                return false
            }
            return true
        }
    }

    // TODO 

    func attack() {}
    func checkHit() {}
    func calculateDamage() {}
    func checkPlayerAttack() {}
    func move() {}
}
