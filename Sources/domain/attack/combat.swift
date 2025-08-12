//
//  combat.swift
//  rogue

public protocol CombatUnit {
    var characteristics: Characteristics { get set }
    var agility: Int { get }
    var strength: Int { get }
    func receiveDamage(_ damage: Int)
    var isDead: Bool { get }
    var weaponDamage: Int? { get }
}

extension CombatUnit {
    public var weaponDamage: Int? { return nil }
}

public struct CombatSystem {
    static func performAttack(from attacker: CombatUnit, to target: CombatUnit) -> AttackResult {
        let hitChance = calculateHitChance(attackerAgility: attacker.agility, defenderAgility: target.agility)
        guard Int.random(in: 1...100) <= hitChance else {
            return .miss
        }
        let damage = attacker.strength + Int.random(in: -2...2) + (attacker.weaponDamage ?? 0)

        target.receiveDamage(damage)
        return .hit(damage: damage)
    }

    private static func calculateHitChance(attackerAgility: Int, defenderAgility: Int) -> Int {
        let baseChance = 70
        let agilityDiff = attackerAgility - defenderAgility
        return max(20, min(95, baseChance + agilityDiff * 2))
    }
}
