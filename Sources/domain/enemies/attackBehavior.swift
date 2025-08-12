//
//  attackBehavior.swift
//  rogue

public enum AttackResult {
    case miss
    case hit(damage: Int)
}

public protocol AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult
}

class DefaultAttack: AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult {
        return CombatSystem.performAttack(from: attacker, to: player)
    }
}

class DrainHealthAttack: DefaultAttack {
    override func attack(attacker: Enemy, player: Player) -> AttackResult {
        let result = super.attack(attacker: attacker, player: player)
        if case .hit = result {
            player.characteristics.maxHealth -= Range(1...5).randomElement() ?? 3
            player.characteristics.health = min(player.characteristics.health, player.characteristics.maxHealth)
        }
        return result
    }
}

class WithSleepAttack: DefaultAttack {
    override func attack(attacker: Enemy, player: Player) -> AttackResult {
        let result = super.attack(attacker: attacker, player: player)
        if case .hit = result, Int.random(in: 1...100) <= 30 {
            player.isAsleep = true
            GameEventManager.shared.notify(.playerSleep)
        }
        return result
    }
}
