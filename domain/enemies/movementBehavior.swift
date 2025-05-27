//
//  movementBehavior.swift
//  rogue

import Foundation

enum DiagonalDirection {
    case topLeftBottomRight
    case topRightBottomLeft

    var opposite: DiagonalDirection {
        switch self {
        case .topLeftBottomRight: return .topRightBottomLeft
        case .topRightBottomLeft: return .topLeftBottomRight
        }
    }

    var moves: Position {
        switch self {
        case .topLeftBottomRight: return Position(1, 1)
        case .topRightBottomLeft: return Position(-1, 1)
        }
    }
}

public protocol MovementBehavior {
    func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position?
}

struct RandomMovement: MovementBehavior {
    var step: Int
    
    init(step: Int = 1) {
        self.step = step
    }
    
    func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position? {
        var attempts = 10
        while attempts > 0 {
            let directions = [(-step,0), (step,0), (0,-step), (0,step)]
            let move = directions.randomElement() ?? (0, 0)
            let newPosition = Position(position.x + move.0, position.y + move.1)
            if gameMap.isWalkable(newPosition) && room.isInsideRoom(newPosition) {
                return newPosition
            }
            attempts -= 1
        }
        return position
    }
}

struct PursueMovement: MovementBehavior {
    func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position? {
        if let path = findPath(from: position, to: playerPosition, in: gameMap), path.count > 1 {
            return path[1]
        }
        return nil
    }
    
    private func findPath(from start: Position, to target: Position, in gameMap: GameMap) -> [Position]? {
        var queue: [(Position, [Position])] = [(start, [start])]
        var visited: Set<Position> = [start]
        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()
            if current == target {
                return path
            }

            let neighbors = [
                Position(current.x + 1, current.y),
                Position(current.x - 1, current.y),
                Position(current.x, current.y + 1),
                Position(current.x, current.y - 1)
            ].filter { gameMap.isWalkable($0) && !visited.contains($0) }

            for neighbor in neighbors {
                visited.insert(neighbor)
                queue.append((neighbor, path + [neighbor]))
            }
        }
        return nil
    }
}

// движение по диагонали
class DiagonalMovement: MovementBehavior {
    private var direction: DiagonalDirection = .topLeftBottomRight

    func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position? {
        let moves = direction.moves
        let newPosition = Position(position.x + moves.x, position.y + moves.y)

        // Если новая позиция валидна - двигаемся и меняем направление
        if room.isInsideRoom(newPosition) && gameMap.isWalkable(newPosition) {
            direction = direction.opposite
            return newPosition
        }

        // Если нельзя двигаться - остаемся на месте, но все равно меняем направление для следующего хода
        direction = direction.opposite
        return position
    }
}

// рандомный телепорт 
struct TeleportMovement: MovementBehavior {
    func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position? {
        // Пытаемся найти валидную позицию за заданное число попыток
        var attempts = 10
        while attempts > 0 {
            let newX = Int.random(in: room.lowLeft.x...room.topRight.x)
            let newY = Int.random(in: room.lowLeft.y...room.topRight.y)
            let newPosition = Position(newX, newY)

            // Проверяем, что позиция валидна (не в стене и доступна для перемещения)
            if room.isInsideRoom(newPosition) && gameMap.isWalkable(newPosition) {
                return newPosition
            }
            attempts -= 1
        }
        // Если не удалось найти валидную позицию, остаёмся на месте
        return position
    }
}
