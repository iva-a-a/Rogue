//
//  movementStrategy.swift
//  rogue


import Foundation

protocol MovementStrategy {
    func move(from position: (x: Int, y: Int), in room: Room, toward playerPosition: (x: Int, y: Int)) -> (x: Int, y: Int)
}

struct RandomMovement: MovementStrategy {
    func move(from position: (x: Int, y: Int), in room: Room, toward playerPosition: (x: Int, y: Int)) -> (x: Int, y: Int) {
        let directions = [(-1,0), (1,0), (0,-1), (0,1)]
        let move = directions.randomElement() ?? (0, 0)
        let newPosition = (x: position.x + move.0, y: position.y + move.1)
        return room.isValidPosition(Position(newPosition.x, newPosition.y)) ? newPosition : position
    }
}

struct PursueMovement: MovementStrategy {
    func move(from position: (x: Int, y: Int), in room: Room, toward playerPosition: (x: Int, y: Int)) -> (x: Int, y: Int) {
        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let newX = position.x + (dx == 0 ? 0 : dx / abs(dx))
        let newY = position.y + (dy == 0 ? 0 : dy / abs(dy))
        let newPosition = (x: newX, y: newY)
        return room.isValidPosition(Position(newX, newY)) ? newPosition : position
    }
}

class DiagonalMovement: MovementStrategy {
    private var direction: DiagonalDirection = .topLeftBottomRight
    
    func move(from position: (x: Int, y: Int), in room: Room, toward playerPosition: (x: Int, y: Int)) -> (x: Int, y: Int) {
        let moves = direction.moves
        let newPosition = Position(position.x + moves.dx, position.y + moves.dy)
        
        // Если новая позиция валидна - двигаемся и меняем направление
        if room.isValidPosition(newPosition) {
            direction = direction.opposite
            return (newPosition.x, newPosition.y)
        }
        
        // Если нельзя двигаться - остаемся на месте, но все равно меняем направление для следующего хода
        direction = direction.opposite
        return (position.x, position.y)
    }
}

struct TeleportMovement: MovementStrategy {
    func move(from position: (x: Int, y: Int), in room: Room, toward playerPosition: (x: Int, y: Int)) -> (x: Int, y: Int) {
        // Пытаемся найти валидную позицию за заданное число попыток
        var attempts = 10
        while attempts > 0 {
            let newX = Int.random(in: room.lowLeft.x...room.topRight.x)
            let newY = Int.random(in: room.lowLeft.y...room.topRight.y)
            let newPosition = Position(newX, newY)
            
            // Проверяем, что позиция валидна (не в стене и доступна для перемещения)
            if room.isValidPosition(newPosition) {
                return (newX, newY)
            }
            attempts -= 1
        }
        // Если не удалось найти валидную позицию, остаёмся на месте
        return (position.x, position.y)
    }
}
