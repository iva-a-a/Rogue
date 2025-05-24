enum AttackResult {
    case miss
    case hit(damage: Int)
}

protocol AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult
}

struct DefaultAttack: AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult {
        let hitChance = attacker.calculateHitChance(
            agility: attacker.characteristics.agility,
            targetAgility: player.characteristics.agility
        )

        guard Int.random(in: 1...100) <= hitChance else {
            return .miss
        }

        let damage = attacker.characteristics.strength + Int.random(in: -2...2)
        player.characteristics.health -= damage
        return .hit(damage: damage)
    }
}

class FirstMissAttack: AttackBehavior {
    private var didMiss = false

    func attack(attacker: Enemy, player: Player) -> AttackResult {
        if !didMiss {
            didMiss = true
            return .miss
        }
        return DefaultAttack().attack(attacker: attacker, player: player)
    }
}

struct DrainHealthAttack: AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult {
        let result = DefaultAttack().attack(attacker: attacker, player: player)
        if case .hit = result {
            player.characteristics.maxHealth -= 5
            player.characteristics.health = min(player.characteristics.health, player.characteristics.maxHealth)
        }
        return result
    }
}

extension Enemy {
    func calculateHitChance(agility: Int, targetAgility: Int) -> Int {
        let baseChance = 70
        let agilityDiff = agility - targetAgility
        return max(20, min(95, baseChance + agilityDiff * 2))
    }
}
