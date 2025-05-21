//
//  enemy.swift
//  rogue

protocol EnemyProtocol {
    var type: EnemyType { get }
    var characteristics: Characteristics { get set }
    var hostility: Int { get }
    var isVisible: Bool { get set }
    func move(in room: Room, playerPosition: Position) -> Position
    func attack(player: Player) -> AttackResult
}

public enum EnemyType {
    case zombie, vampire, ghost, ogre, snakeMage
}

enum AttackResult {
    case miss
    case hit(damage: Int)
}

public class Enemy: EnemyProtocol {
    let type: EnemyType
    var characteristics: Characteristics
    let hostility: Int
    var isVisible: Bool = true
    let movementStrategy: MovementStrategy
    var isResting: Bool = false

    public init(type: EnemyType, characteristics: Characteristics, hostility: Int, movementStrategy: MovementStrategy) {
        self.type = type
        self.characteristics = characteristics
        self.hostility = hostility
        self.movementStrategy = movementStrategy
    }

    func move(in room: Room, playerPosition: Position) -> Position {
        let newPosition = movementStrategy.move(
            from: (x: characteristics.position.x, y: characteristics.position.y),
            in: room,
            toward: (x: playerPosition.x, y: playerPosition.y)
        )
        characteristics.position = Position(newPosition.x, newPosition.y)
        return characteristics.position
    }

    func attack(player: Player) -> AttackResult {
        // Проверка на попадание на основе ловкости
        let hitChance = calculateHitChance(agility: characteristics.agility, targetAgility: player.characteristics.agility)
        guard Int.random(in: 1...100) <= hitChance else {
            return .miss
        }

        // Расчет урона
        let damage = calculateDamage()
        player.characteristics.health -= damage
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
        return characteristics.strength + Int.random(in: -2...2)
    }

    func randomMove(in room: Room, step: Int = 1) -> Position {
        let directions = [
            Position(step, 0),
            Position(-step, 0),
            Position(0, step),
            Position(0, -step)
        ]

        let possibleMoves = directions.map {
            Position(characteristics.position.x + $0.x, characteristics.position.y + $0.y)
        }.filter { room.isInsideRoom($0) }

        return possibleMoves.randomElement() ?? characteristics.position
    }
}


