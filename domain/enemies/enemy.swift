//
//  enemy.swift
//  rogue

enum EnemyType {
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

protocol EnemyProtocol {
    var type: EnemyType { get }
    var characteristics: Characteristics { get set }
    var hostility: Int { get }
    var isVisible: Bool { get set }

    var movementBehavior: MovementBehavior { get }
    var pursuitBehavior: MovementBehavior { get }
    var attackBehavior: AttackBehavior { get }

    func attack(_ player: Player) -> AttackResult
    func move(_ level: Level)

    var indexRoom: Int { get set }

}

public class Enemy: EnemyProtocol {

    var type: EnemyType
    public var characteristics: Characteristics
    var hostility: Int = 0
    var isVisible: Bool = true
    var movementBehavior: any MovementBehavior
    var pursuitBehavior: any MovementBehavior
    var attackBehavior: any AttackBehavior
    var indexRoom: Int

    init(type: EnemyType, characteristics: Characteristics, hostility: Int, movementBehavior: any MovementBehavior, pursuitBehavior: any MovementBehavior, attackBehavior: any AttackBehavior, indexRoom: Int) {
        self.type = type
        self.characteristics = characteristics
        self.hostility = hostility
        self.movementBehavior = movementBehavior
        self.pursuitBehavior = pursuitBehavior
        self.attackBehavior = attackBehavior
        self.indexRoom = indexRoom
    }

    public func move(_ level: Level) {
        var pos: Position?
        if shouldPursue(player: level.player) {
            pos = self.pursuitBehavior.move(from: characteristics.position, toward: level.player.characteristics.position, in: level.rooms[indexRoom], in: level.gameMap)
            isVisible = true
        }
        if pos == nil {
          pos = self.movementBehavior.move(from: characteristics.position, toward: level.player.characteristics.position, in: level.rooms[indexRoom], in: level.gameMap)
        }
        level.gameMap.rewrite(from: characteristics.position, to: pos!)
        characteristics.position = pos!
        if let newRoomIndex = level.rooms.firstIndex(where: { $0.isInsideRoom(pos!) }), newRoomIndex != indexRoom {
            indexRoom = newRoomIndex
        }
    }

    public func attack(_ player: Player) -> AttackResult {
        isVisible = true
        return attackBehavior.attack(attacker: self, player: player)
    }

    private func shouldPursue(player: Player) -> Bool {
        let distance = abs(characteristics.position.x - player.characteristics.position.x) + abs(characteristics.position.y - player.characteristics.position.y)
        return distance <= hostility / 10 // Радиус преследования зависит от враждебности
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
