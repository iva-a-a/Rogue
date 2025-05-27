//
// enemyTypes.swift
//  rogue

class Zombie: Enemy {
    init() {
        let characteristics = Characteristics(position: Position(0, 0), maxHealth: 80, health: 80, agility: 3, strength: 12)
        super.init(
            type: .zombie,
            characteristics: characteristics,
            hostility: 7,
            movementBehavior: RandomMovement(step: 1),
            pursuitBehavior: PursueMovement(),
            attackBehavior: DefaultAttack(),
            indexRoom: 9
        )
    }
}

class Vampire: Enemy {
    init() {
        let characteristics = Characteristics(position: Position(0, 0), maxHealth: 60, health: 60, agility: 15, strength: 10)
        super.init(
            type: .vampire,
            characteristics: characteristics,
            hostility: 9,
            movementBehavior: RandomMovement(step: 1),
            pursuitBehavior: PursueMovement(),
            attackBehavior: DrainHealthAttack(),
            indexRoom: 9
        )
    }
}

class Ghost: Enemy {
    init() {
        let characteristics = Characteristics(position: Position(0, 0), maxHealth: 40, health: 40, agility: 18, strength: 5)
        super.init(
            type: .ghost,
            characteristics: characteristics,
            hostility: 6,
            movementBehavior: TeleportMovement(),
            pursuitBehavior: PursueMovement(),
            attackBehavior: DefaultAttack(),
            indexRoom: 9
        )
    }

    override func move(level: Level) {
        super.move(level: level)
        // добавляем изменение видимости
        isVisible = Int.random(in: 1...100) > 20
    }
}

class Ogre: Enemy {
    var isResting: Bool = false
    
    init() {
        let characteristics = Characteristics(position: Position(0, 0), maxHealth: 120, health: 120, agility: 2, strength: 25)
        super.init(
            type: .ogre,
            characteristics: characteristics,
            hostility: 5,
            movementBehavior: RandomMovement(step: 2),
            pursuitBehavior: PursueMovement(),
            attackBehavior: DefaultAttack(),
            indexRoom: 9
        )
    }

    override func move(level: Level) {
        guard !isResting else {
            // eсли отдыхает - остаемся на месте
            return
        }
        super.move(level: level)
    }

    override func attack(player: Player) -> AttackResult {
        var result = AttackResult.miss
        if !isResting {
            result = attackBehavior.attack(attacker: self, player: player)
        }
        isResting = !isResting
        return result
    }
}

class SnakeMage: Enemy {
    init() {
        let characteristics = Characteristics(position: Position(0, 0), maxHealth: 50, health: 50, agility: 20, strength: 8)
        super.init(
            type: .snakeMage,
            characteristics: characteristics,
            hostility: 8,
            movementBehavior: DiagonalMovement(),
            pursuitBehavior: PursueMovement(),
            attackBehavior: WithSleepAttack(),
            indexRoom: 9
        )
    }
}
