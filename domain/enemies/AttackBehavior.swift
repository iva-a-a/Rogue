public enum AttackResult {
    case miss
    case hit(damage: Int)
}

protocol AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult
}

class DefaultAttack: AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult {
        return CombatSystem.performAttack(from: attacker, to: player)
    }
}

class FirstMissAttack: DefaultAttack {
    private var didMiss = false
    override func attack(attacker: Enemy, player: Player) -> AttackResult {
        if !didMiss {
            didMiss = true
            return .miss
        }
        return super.attack(attacker: attacker, player: player)
    }
}

class DrainHealthAttack: DefaultAttack {
    override func attack(attacker: Enemy, player: Player) -> AttackResult {
        let result = super.attack(attacker: attacker, player: player)
        if case .hit = result {
            player.characteristics.maxHealth -= 5
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
