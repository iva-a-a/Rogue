enum AttackResult {
    case miss
    case hit(damage: Int)
}

protocol AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult
}

class DefaultAttack: AttackBehavior {
    func attack(attacker: Enemy, player: Player) -> AttackResult {
        let hitChance = calculateHitChance(
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
    
    private func calculateHitChance(agility: Int, targetAgility: Int) -> Int {
        let baseChance = 70
        let agilityDiff = agility - targetAgility
        return max(20, min(95, baseChance + agilityDiff * 2))
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
        }
        return result
    }
}
