//
//  GameEntities.swift
//  
//
//  Created by Ginn on 15.05.2025.
//

extension Enemy {
    func shouldPursue(playerPosition: Position) -> Bool {
        let distance = abs(position.x - playerPosition.x) + abs(position.y - playerPosition.y)
        return distance <= hostility / 10 // Радиус преследования зависит от враждебности
    }

    func pursuePlayer(room: Room, playerPosition: Position, step: Int = 1) -> Position {
        guard let path = findPath(to: playerPosition, in: room) else {
            return randomMove(in: room, step: step) // Используем общий метод
        }
        
        let nextStepIndex = min(step, path.count - 2)
        return path[nextStepIndex + 1]
    }

    private func findPath(to target: Position, in room: Room) -> [Position]? {
        var queue: [(Position, [Position])] = [(position, [position])]
        var visited: Set<Position> = [position]

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
            ].filter { room.isValidPosition($0) && !visited.contains($0) }

            for neighbor in neighbors {
                visited.insert(neighbor)
                queue.append((neighbor, path + [neighbor]))
            }
        }

        return nil // Путь не найден
    }
}

// MARK: - Room (Simplified for Example)
struct Room {
    let bounds: (minX: Int, maxX: Int, minY: Int, maxY: Int)

    func isValidPosition(_ point: Position) -> Bool {
        return point.x >= bounds.minX && point.x <= bounds.maxX &&
               point.y >= bounds.minY && point.y <= bounds.maxY
    }
}

// MARK: - Player (Simplified for Example)
class Player {
    var health: Int
    var maxHealth: Int
    var agility: Int
    var strength: Int
    var position: Position
    var sleepTurns: Int = 0
    var isAsleep: Bool {
        get { return sleepTurns > 0 }
        set { sleepTurns = newValue ? 1 : 0 }
    }

    init(health: Int, maxHealth: Int, agility: Int, strength: Int, position: Position) {
        self.health = health
        self.maxHealth = maxHealth
        self.agility = agility
        self.strength = strength
        self.position = position
    }
}
