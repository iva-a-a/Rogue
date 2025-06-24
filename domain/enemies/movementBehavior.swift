//
//  movementBehavior.swift
//  rogue

import Foundation

public protocol MovementBehavior {
    func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position?
}

public struct RandomMovement: MovementBehavior {
    public var step: Int

    public init(step: Int = 1) {
        self.step = step
    }

    public func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position? {
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

public struct PursueMovement: MovementBehavior {
    public init() {}

    public func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position? {
        if let path = findPath(from: position, to: playerPosition, in: gameMap), path.count > 1 {
            return path[1]
        }
        return nil
    }
    
    private func findPath(from start: Position, to target: Position, in gameMap: GameMap) -> [Position]? {
        let directions = [
            Position(0, 1),
            Position(1, 0),
            Position(0, -1),
            Position(-1, 0)
        ]
        
        var visited: Set<Position> = [start]
        var queue: [(position: Position, path: [Position])] = [(start, [start])]

        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()
            if current == target {
                return path
            }

            for dir in directions {
                let neighbor = Position(current.x + dir.x, current.y + dir.y)
                if (gameMap.isWalkable(neighbor) || neighbor == target) && !visited.contains(neighbor) {
                    visited.insert(neighbor)
                    queue.append((neighbor, path + [neighbor]))
                }
            }
        }
        return nil
    }
}

public class DiagonalMovement: MovementBehavior {
    private var movingRight = true
    private var goingDownNext = true

    public init() {}

    public func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position? {
        let dy = movingRight ? 1 : -1
        let dx = goingDownNext ? 1 : -1

        let candidate = Position(position.x + dx, position.y + dy)

        goingDownNext.toggle()
        if room.isInsideRoom(candidate) && gameMap.isWalkable(candidate) {
            return candidate
        }
        let testY = Position(position.x, position.y + dy)
        if !room.isInsideRoom(testY) || !gameMap.isWalkable(testY) {
            movingRight.toggle()
        }
        return position
    }
}
 
public struct TeleportMovement: MovementBehavior {
    public init() {}

    public func move(from position: Position, toward playerPosition: Position, in room: Room, in gameMap: GameMap) -> Position? {

        var attempts = 10
        while attempts > 0 {
            let newX = Int.random(in: room.lowLeft.x...room.topRight.x)
            let newY = Int.random(in: room.lowLeft.y...room.topRight.y)
            let newPosition = Position(newX, newY)

            if room.isInsideRoom(newPosition) && gameMap.isWalkable(newPosition) {
                return newPosition
            }
            attempts -= 1
        }
        return position
    }
}
