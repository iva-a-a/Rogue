//
//  enemyTypes.swift
//  rogue

class Zombie: Enemy {
    init(characteristics: Characteristics, hostility: Int) {
        super.init(
            type: .zombie,
            characteristics: characteristics,
            hostility: hostility,
            movementBehavior: RandomMovement(step: 1),
            pursuitBehavior: PursueMovement(),
            attackBehavior: DefaultAttack(),
            indexRoom: 9
        )
    }
}

class Vampire: Enemy {
    init(characteristics: Characteristics, hostility: Int) {
        super.init(
            type: .vampire,
            characteristics: characteristics,
            hostility: hostility,
            movementBehavior: RandomMovement(step: 1),
            pursuitBehavior: PursueMovement(),
            attackBehavior: DrainHealthAttack(),
            indexRoom: 9
        )
    }
}

class Ghost: Enemy {
    init(characteristics: Characteristics, hostility: Int) {
        super.init(
            type: .ghost,
            characteristics: characteristics,
            hostility: hostility,
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

    init(characteristics: Characteristics, hostility: Int) {
        super.init(
            type: .ogre,
            characteristics: characteristics,
            hostility: hostility,
            movementBehavior: RandomMovement(step: 2),
            pursuitBehavior: PursueMovement(),
            attackBehavior: DefaultAttack(),
            indexRoom: 9
        )
    }

    override func move(level: Level) {
        if isResting {
            isResting = false
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
    init(characteristics: Characteristics, hostility: Int) {
        super.init(
            type: .snakeMage,
            characteristics: characteristics,
            hostility: hostility,
            movementBehavior: DiagonalMovement(),
            pursuitBehavior: PursueMovement(),
            attackBehavior: WithSleepAttack(),
            indexRoom: 9
        )
    }
}

public protocol DepictsItem {
    var depictsItem: Bool { get set }
}

class Mimic: Enemy {
    var depictsItem: Bool = true
    
    init(characteristics: Characteristics, hostility: Int) {
        super.init(
            type: .mimic,
            characteristics: characteristics,
            hostility: hostility,
            movementBehavior: RandomMovement(step: 0),
            pursuitBehavior: PursueMovement(),
            attackBehavior: DefaultAttack(),
            indexRoom: 9
        )
    }
    
    override func attack(player: Player) -> AttackResult {
        depictsItem = false
        return attackBehavior.attack(attacker: self, player: player)
    }
}

extension Mimic: DepictsItem {}
