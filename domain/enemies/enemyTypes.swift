//
//  EnemyTypes.swift
//  
//
//  Created by Ginn on 15.05.2025.
//

// MARK: - Zombie
class Zombie: Enemy {
    init(position: Position) {
        super.init(
            type: .zombie,
            health: 100, // Высокое здоровье
            maxHealth: 100,
            agility: 20, // Низкая ловкость
            strength: 50, // Средняя сила
            hostility: 50, // Средняя враждебность
            position: position,
            movementStrategy: RandomMovement()
        )
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if shouldPursue(playerPosition: playerPosition) {
            position = pursuePlayer(room: room, playerPosition: playerPosition)
        } else {
            let newPosition = movementStrategy.move(from: (x: position.x, y: position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
            position = Position(newPosition.x, newPosition.y)
        }
        return position
    }

    private func randomMove(in room: Room) -> Point {
        let possibleMoves = [
            Position(position.x + 1, position.y),
            Position(position.x - 1, position.y),
            Position(position.x, position.y + 1),
            Position(position.x, position.y - 1)
        ].filter { room.isValidPosition($0) }
        return possibleMoves.randomElement() ?? position
    }
}

// MARK: - Vampire
class Vampire: Enemy {
    private var isFirstHit = true

    init(position: Position) {
        super.init(
            type: .vampire,
            health: 80, // Высокое здоровье
            maxHealth: 80,
            agility: 80, // Высокая ловкость
            strength: 40, // Средняя сила
            hostility: 80, // Высокая враждебность
            position: position,
            movementStrategy: RandomMovement()
        )
    }

    override func attack(player: Player) -> AttackResult {
        if isFirstHit {
            isFirstHit = false
            return .miss // Первый удар всегда промах
        }
        let result = super.attack(player: player)
        if case .hit = result {
            player.maxHealth -= 5 // Отнимает максимальное здоровье
            player.health = min(player.health, player.maxHealth)
        }
        return result
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if shouldPursue(playerPosition: playerPosition) {
            return pursuePlayer(room: room, playerPosition: playerPosition)
        }
        let newPosition = movementStrategy.move(from: (x: position.x, y: position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
        position = Position(newPosition.x, newPosition.y)
        return position
    }
}

// MARK: - Ghost
class Ghost: Enemy {
    init(position: Position) {
        super.init(
            type: .ghost,
            health: 30,
            maxHealth: 30,
            agility: 90,
            strength: 20,
            hostility: 20,
            position: position,
            movementStrategy: TeleportMovement() // Используем стратегию телепортации
        )
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if shouldPursue(playerPosition: playerPosition) {
            return pursuePlayer(room: room, playerPosition: playerPosition)
        }
        // Телепортация с шансом 30%
        if Int.random(in: 1...100) <= 30 {
            let newPosition = movementStrategy.move(from: (x: position.x, y: position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
            position = Position(newPosition.x, newPosition.y)
            isVisible = Int.random(in: 1...100) > 20 // 80% шанс стать видимым после телепортации
            return position
        }
        // Если не телепортировался, остается на месте и может стать невидимым
        isVisible = Int.random(in: 1...100) > 20
        return position
    }
}

// MARK: - Ogre
class Ogre: Enemy {
    init(position: Position) {
        super.init(
            type: .ogre,
            health: 150, // Очень высокое здоровье
            maxHealth: 150,
            agility: 20, // Низкая ловкость
            strength: 90, // Очень высокая сила
            hostility: 50, // Средняя враждебность
            position: position,
            movementStrategy: RandomMovement()
        )
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if isResting {
            isResting = false
            return position
        }
        
        // Для преследования
        if shouldPursue(playerPosition: playerPosition) {
            let newPosition = pursuePlayer(room: room, playerPosition: playerPosition, step: 2)
            position = newPosition
            return newPosition
        }
        
        // Для обычного движения (с шагом 2)
        let basePosition = super.move(in: room, playerPosition: playerPosition)
        let deltaX = basePosition.x - position.x
        let deltaY = basePosition.y - position.y
        let finalPosition = Position(
            position.x + deltaX * 2,
            position.y + deltaY * 2
        )
        
        position = room.isValidPosition(finalPosition) ? finalPosition : basePosition
        return position
    }

    override func attack(player: Player) -> AttackResult {
        let result = super.attack(player: player)
        isResting = true // Отдых после атаки
        return result
    }

    internal override func randomMove(in room: Room, step: Int) -> Position {
        let possibleMoves = [
            Position(position.x + step, position.y),
            Position(position.x - step, position.y),
            Position(position.x, position.y + step),
            Position(position.x, position.y - step)
        ].filter { room.isValidPosition($0) }
        return possibleMoves.randomElement() ?? position
    }
}

// MARK: - Snake Mage
class SnakeMage: Enemy {
    init(position: Position) {
        super.init(
            type: .snakeMage,
            health: 60,
            maxHealth: 60,
            agility: 95,
            strength: 30,
            hostility: 80,
            position: position,
            movementStrategy: DiagonalMovement() // Используем новую стратегию
        )
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if shouldPursue(playerPosition: playerPosition) {
            return pursuePlayer(room: room, playerPosition: playerPosition)
        }
        let newPosition = movementStrategy.move(from: (x: position.x, y: position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
        position = Position(newPosition.x, newPosition.y)
        // Если движение не удалось (например, стена), используем случайное движение
        if newPosition.x == position.x && newPosition.y == position.y {
            let fallback = RandomMovement()
            let fallbackPosition = fallback.move(from: (x: position.x, y: position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
            position = Position(fallbackPosition.x, fallbackPosition.y)
        }
        return position
    }

    override func attack(player: Player) -> AttackResult {
        let result = super.attack(player: player)
        if case .hit = result, Int.random(in: 1...100) <= 30 {
            player.isAsleep = true
        }
        return result
    }
}

// MARK: - Diagonal Direction
enum DiagonalDirection {
    case topLeftBottomRight
    case topRightBottomLeft

    var opposite: DiagonalDirection {
        switch self {
        case .topLeftBottomRight: return .topRightBottomLeft
        case .topRightBottomLeft: return .topLeftBottomRight
        }
    }

    var moves: (dx: Int, dy: Int) {
        switch self {
        case .topLeftBottomRight: return (1, 1)
        case .topRightBottomLeft: return (-1, 1)
        }
    }
}
