//
//  enemy.swift
//  rogue

protocol EnemyProtocol {
    var type: EnemyType { get }
    var characteristics: Characteristics { get set }
    var hostility: Int { get }
    var isVisible: Bool { get set }
    func move(in room: Room, map: GameMap, playerPosition: Position) -> Position
    func attack(player: Player) -> AttackResult
}

enum EnemyType {
    case zombie, vampire, ghost, ogre, snakeMage
}

class Enemy: EnemyProtocol {
    let type: EnemyType
    var characteristics: Characteristics
    let hostility: Int
    var isVisible: Bool = true
    var isResting: Bool = false

    let movementStrategy: MovementStrategy
    let attackBehavior: AttackBehavior
    let pursuitBehavior: PursuitBehavior

    init(
        type: EnemyType,
        characteristics: Characteristics,
        hostility: Int,
        movementStrategy: MovementStrategy,
        attackBehavior: AttackBehavior,
        pursuitBehavior: PursuitBehavior
    ) {
        self.type = type
        self.characteristics = characteristics
        self.hostility = hostility
        self.movementStrategy = movementStrategy
        self.attackBehavior = attackBehavior
        self.pursuitBehavior = pursuitBehavior
    }
    
    @discardableResult
    func move(in room: Room, map: GameMap, playerPosition: Position) -> Position {
        let oldPosition = characteristics.position
        var newPosition: Position

        if pursuitBehavior.shouldPursue(enemy: self, playerPosition: playerPosition) {
            newPosition = pursuitBehavior.pursue(enemy: self, room: room, playerPosition: playerPosition, step: 1)
        } else {
            let newPosTuple = movementStrategy.move(
                from: (characteristics.position.x, characteristics.position.y),
                in: room,
                toward: (playerPosition.x, playerPosition.y)
            )
            newPosition = Position(newPosTuple.x, newPosTuple.y)
        }

        // Проверяем, доступна ли позиция
        if map.isWalkable(newPosition) {
            map.addPosition(oldPosition)
            map.removePosition(newPosition)
            characteristics.position = newPosition
        }

        return characteristics.position
    }
    
    func attack(player: Player) -> AttackResult {
        attackBehavior.attack(attacker: self, player: player)
    }
    @discardableResult
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
    func findPath(to target: Position, in room: Room) -> [Position]? {
            var queue: [(Position, [Position])] = [(characteristics.position, [])]
            var visited: Set<Position> = [characteristics.position]

            while !queue.isEmpty {
                let (current, path) = queue.removeFirst()

                if current == target {
                    return path + [current]
                }

                for direction in [
                    Position(0, 1), Position(0, -1),
                    Position(1, 0), Position(-1, 0)
                ] {
                    let next = Position(current.x + direction.x, current.y + direction.y)

                    if room.isValidPosition(next),
                       !visited.contains(next) {
                        visited.insert(next)
                        queue.append((next, path + [current]))
                    }
                }
            }

            return nil // путь не найден
        }
}
