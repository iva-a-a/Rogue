//
//  gameEntities.swift
//  rogue

extension Enemy {
    func shouldPursue(playerPosition: Position) -> Bool {
        let distance = abs(characteristics.position.x - playerPosition.x) + abs(characteristics.position.y - playerPosition.y)
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
        var queue: [(Position, [Position])] = [(characteristics.position, [characteristics.position])]
        var visited: Set<Position> = [characteristics.position]

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
            ].filter { room.isInsideRoom($0) && !visited.contains($0) }

            for neighbor in neighbors {
                visited.insert(neighbor)
                queue.append((neighbor, path + [neighbor]))
            }
        }

        return nil // Путь не найден
    }
}
