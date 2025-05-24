
protocol PursuitBehavior {
    func shouldPursue(enemy: Enemy, playerPosition: Position) -> Bool
    func pursue(enemy: Enemy, room: Room, playerPosition: Position, step: Int) -> Position
}

struct DefaultPursuit: PursuitBehavior {
    func shouldPursue(enemy: Enemy, playerPosition: Position) -> Bool {
        let distance = abs(enemy.characteristics.position.x - playerPosition.x) +
                       abs(enemy.characteristics.position.y - playerPosition.y)
        return distance <= enemy.hostility / 10
    }

    func pursue(enemy: Enemy, room: Room, playerPosition: Position, step: Int = 1) -> Position {
        guard let path = enemy.findPath(to: playerPosition, in: room), path.count > 1 else {
            return enemy.randomMove(in: room, step: step)
        }

        let nextStepIndex = min(step, path.count - 2)
        return path[nextStepIndex + 1]
    }
}
