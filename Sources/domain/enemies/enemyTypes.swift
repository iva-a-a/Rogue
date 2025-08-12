//
//  enemyTypes.swift
//  rogue

public class Zombie: Enemy {
    public init(characteristics: Characteristics, hostility: Int) {
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

public class Vampire: Enemy, AttackInterceptable {

    private var wasFirstAttacked = false

    public init(characteristics: Characteristics, hostility: Int) {
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

    public func interceptAttack(from attacker: CombatUnit) -> AttackResult? {
        guard !wasFirstAttacked else { return nil }
        wasFirstAttacked = true
        return .miss
    }
    
    public func getWasFirstAttacked() -> Bool {
        return wasFirstAttacked
    }
    
    public func setWasFirstAttacked(_ value: Bool) {
        wasFirstAttacked = value
    }
}

public class Ghost: Enemy {
    public init(characteristics: Characteristics, hostility: Int) {
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

    public override func move(level: Level) {
        super.move(level: level)
        isVisible = Int.random(in: 1...100) > 20
    }
}

public class Ogre: Enemy {
    private var isResting: Bool = false

    public init(characteristics: Characteristics, hostility: Int) {
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

    public override func move(level: Level) {
        if isResting {
            isResting = false
            return
        }
        super.move(level: level)
    }

    public override func attack(player: Player) -> AttackResult {
        var result = AttackResult.miss
        if !isResting {
            result = attackBehavior.attack(attacker: self, player: player)
        }
        isResting = !isResting
        return result
    }
    
    public func getIsResting() -> Bool {
        return isResting
    }
    
    public func setIsResting(_ isResting: Bool) {
        self.isResting = isResting
    }
}

public class SnakeMage: Enemy {
    public init(characteristics: Characteristics, hostility: Int) {
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
    var disguisedItemType: ItemType { get set }
}

public class Mimic: Enemy {
    public var depictsItem: Bool = true
    public var disguisedItemType: ItemType = Mimic.randomDisguisedItem()

    public init(characteristics: Characteristics, hostility: Int) {

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

    public override func move(level: Level) {
        let distanceToPlayer = abs(characteristics.position.x - level.player.characteristics.position.x) +
        abs(characteristics.position.y - level.player.characteristics.position.y)
        if distanceToPlayer == 2 && depictsItem == false {
            hostility = 3
        }
        super.move(level: level)
    }

    public override func attack(player: Player) -> AttackResult {
        depictsItem = false
        return attackBehavior.attack(attacker: self, player: player)
    }

    private static func randomDisguisedItem() -> ItemType {
        let possibleItems: [ItemType] = [
            .food(.apple),
            .weapon(.dagger),
            .scroll(.agility),
            .elixir(.agility)
        ]
        return possibleItems.randomElement() ?? .food(.apple)
    }
}

extension Mimic: DepictsItem {}
