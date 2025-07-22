//
//  enemy.swift
//  rogue

public enum EnemyType: String {
    case zombie, vampire, ghost, ogre, snakeMage, mimic
    
    var name: String {
        switch self {
        case .zombie: return "Zombie"
        case .vampire: return "Vampire"
        case .ghost: return "Ghost"
        case .ogre: return "Ogre"
        case .snakeMage: return "Snake-Mage"
        case .mimic: return "Mimic"
        }
    }
}

public protocol EnemyProtocol {
    var type: EnemyType { get }
    var characteristics: Characteristics { get set }
    var hostility: Int { get }
    var isVisible: Bool { get set }

    var movementBehavior: MovementBehavior { get }
    var pursuitBehavior: MovementBehavior { get }
    var attackBehavior: AttackBehavior { get }

    func attack(player: Player) -> AttackResult
    func move(level: Level)

    var indexRoom: Int { get set }

}

public protocol AttackInterceptable: EnemyProtocol {
    func interceptAttack(from attacker: CombatUnit) -> AttackResult?
}

public class Enemy: EnemyProtocol {

    public var type: EnemyType
    public var characteristics: Characteristics
    public var hostility: Int = 0
    public var isVisible: Bool = true
    public var movementBehavior: any MovementBehavior
    public var pursuitBehavior: any MovementBehavior
    public var attackBehavior: any AttackBehavior
    public var indexRoom: Int

    init(type: EnemyType,
         characteristics: Characteristics,
         hostility: Int,
         movementBehavior: any MovementBehavior,
         pursuitBehavior: any MovementBehavior,
         attackBehavior: any AttackBehavior,
         indexRoom: Int) {

        self.type = type
        self.characteristics = characteristics
        self.hostility = hostility
        self.movementBehavior = movementBehavior
        self.pursuitBehavior = pursuitBehavior
        self.attackBehavior = attackBehavior
        self.indexRoom = indexRoom
    }

    public func move(level: Level) {
        var pos: Position?
        if shouldPursue(player: level.player) {
            pos = self.pursuitBehavior.move(from: characteristics.position,
                                            toward: level.player.characteristics.position, in: level.rooms[indexRoom],
                                            in: level.gameMap)
            isVisible = true
            if let targetPos = pos {
                for door in level.coloredDoors {
                    if door.position == targetPos && door.isUnlocked == false {
                        pos = nil
                        break
                    }
                }
            }
        }
        if pos == nil {
          pos = self.movementBehavior.move(from: characteristics.position,
                                           toward: level.player.characteristics.position, in: level.rooms[indexRoom],
                                           in: level.gameMap)
        }
        level.gameMap.rewrite(from: characteristics.position, to: pos!)
        characteristics.position = pos!
        if let newRoomIndex = level.rooms.firstIndex(where: { $0.isInsideRoom(pos!) }), newRoomIndex != indexRoom {
            indexRoom = newRoomIndex
        }
    }

    public func attack(player: Player) -> AttackResult {
        isVisible = true
        return attackBehavior.attack(attacker: self, player: player)
    }

    private func shouldPursue(player: Player) -> Bool {
        let distance = abs(characteristics.position.x - player.characteristics.position.x)
                    + abs(characteristics.position.y - player.characteristics.position.y)
        let pursuitRadius = max(1, hostility * 2 / 3)
        return distance <= pursuitRadius
    }
}

extension Enemy: CombatUnit {
    public var agility: Int { characteristics.agility }
    public var strength: Int { characteristics.strength }

    public func receiveDamage(_ damage: Int) {
        characteristics.health -= damage
        characteristics.health = max(0, characteristics.health)
    }

    public var isDead: Bool {
        characteristics.health <= 0
    }
}
