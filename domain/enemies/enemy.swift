//
//  Enemy.swift
//  rogue

// Domain Layer
// MARK: - Enemy Protocol
protocol EnemyProtocol {
    var type: EnemyType { get }
    var health: Int { get set }
    var maxHealth: Int { get }
    var agility: Int { get }
    var strength: Int { get }
    var hostility: Int { get }
    var position: Position { get set }
    var isVisible: Bool { get set }
    func move(in room: Room, playerPosition: Position) -> Position
    func attack(player: Player) -> AttackResult
}

enum EnemyType {
    case zombie, vampire, ghost, ogre, snakeMage
}

// MARK: - Base Enemy
class Enemy: EnemyProtocol {
    let type: EnemyType
    var health: Int
    let maxHealth: Int
    let agility: Int
    let strength: Int
    let hostility: Int
    var position: Position
    var isVisible: Bool = true
    let movementStrategy: MovementStrategy
    var isResting: Bool = false

    init(type: EnemyType, health: Int, maxHealth: Int, agility: Int, strength: Int, hostility: Int, position: Position, movementStrategy: MovementStrategy) {
        self.type = type
        self.health = health
        self.maxHealth = maxHealth
        self.agility = agility
        self.strength = strength
        self.hostility = hostility
        self.position = position
        self.movementStrategy = movementStrategy
    }

    func move(in room: Room, playerPosition: Position) -> Position {
        let newPosition = movementStrategy.move(
            from: (x: position.x, y: position.y),
            in: room,
            toward: (x: playerPosition.x, y: playerPosition.y)
        )
        position = Position(newPosition.x, newPosition.y)
        return position
    }

    func attack(player: Player) -> AttackResult {
        // Проверка на попадание на основе ловкости
        let hitChance = calculateHitChance(agility: agility, targetAgility: player.agility)
        guard Int.random(in: 1...100) <= hitChance else {
            return .miss
        }

        // Расчет урона
        let damage = calculateDamage()
        player.health -= damage
        return .hit(damage: damage)
    }

    private func calculateHitChance(agility: Int, targetAgility: Int) -> Int {
        // Пример формулы: шанс попадания зависит от ловкости атакующего и цели
        let baseChance = 70
        let modifier = agility - targetAgility
        return max(10, min(90, baseChance + modifier))
    }

    private func calculateDamage() -> Int {
        // Базовый урон на основе силы
        return strength + Int.random(in: -2...2)
    }
    func randomMove(in room: Room, step: Int = 1) -> Position {
        let directions = [
            Position(step, 0),
            Position(-step, 0),
            Position(0, step),
            Position(0, -step)
        ]
        
        let possibleMoves = directions.map {
            Position(position.x + $0.x, position.y + $0.y)
        }.filter { room.isValidPosition($0) }
        
        return possibleMoves.randomElement() ?? position
    }
}

// MARK: - Attack Result
enum AttackResult {
    case miss
    case hit(damage: Int)
}
