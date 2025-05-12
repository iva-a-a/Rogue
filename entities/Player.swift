import Foundation

struct Character {
    var coords: Position 
    var health: Int
    var agility: Int 
    var strength: Int
}
// TODO: class
class Player {
    var baseStats: Character 
    var backpack: Backpack

    var maxHP: Int
    var weapon: Weapon
    var elixirBuffs: Buffs

    init(baseStats: Character, backpack: Backpack, maxHP: Int, weapon: Weapon, elixirBuffs: Buffs) {
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
        let weapon = Weapon(strength: 0, name: "")
        let elixirBuffs = Buffs(maxHealth: [], agility: [], strength: [])
        self.init(baseStats: baseStats, backpack: backpack, maxHP: maxHP, weapon: weapon, elixirBuffs: elixirBuffs)
    }

    func eatFood(food: Food) {
        baseStats.health = (baseStats.health + food.toRegen > maxHP ? maxHP : baseStats.health + food.toRegen)
    }

    func drinkElixir(elixir: Elixir) {
        switch elixir.stat {
            case .health:
                elixirBuffs.maxHealth.append(Buf(statIncrease: elixir.increase, effectEnd: Date() + elixir.duration))
                maxHP += elixir.increase
                baseStats.health += elixir.increase
            case .agility:
                elixirBuffs.agility.append(Buf(statIncrease: elixir.increase, effectEnd: Date() + elixir.duration))
                baseStats.agility += elixir.increase
            case .strength:
                elixirBuffs.strength.append(Buf(statIncrease: elixir.increase, effectEnd: Date() + elixir.duration))
                baseStats.strength += elixir.increase
            default: 
                break
        }
    }

    func readScroll(scroll: Scroll) {
        switch scroll.stat {
            case .health:
                maxHP += scroll.increase
                baseStats.health += scroll.increase
            case .agility:
                baseStats.agility += scroll.increase
            case .strength:
                baseStats.strength += scroll.increase
            default:
                break
        }
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
}
