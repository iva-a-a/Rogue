//
//  enemy.swift
//  rogue

enum EnemyType {
    case zombie, vampire, ghost, ogre, snakeMage
}

protocol EnemyProtocol {
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


class Enemy: EnemyProtocol {
    
    var type: EnemyType
    var characteristics: Characteristics
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
    
    func move(level: Level) {
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
    }
    
    func attack(player: Player) -> AttackResult {
        attackBehavior.attack(attacker: self, player: player)
    }
    
    private func shouldPursue(player: Player) -> Bool {
        let distance = abs(characteristics.position.x - player.characteristics.position.x) + abs(characteristics.position.y - player.characteristics.position.y)
        return distance <= hostility / 10 // Радиус преследования зависит от враждебности
    }
}
