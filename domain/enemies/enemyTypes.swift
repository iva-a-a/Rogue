//
//  enemyTypes.swift
//  rogue

class Zombie: Enemy {
    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 80, health: 80, agility: 3, strength: 12)
        super.init(type: .zombie, characteristics: characteristics, hostility: 7, movementStrategy: RandomMovement())
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if shouldPursue(playerPosition: playerPosition) {
            characteristics.position = pursuePlayer(room: room, playerPosition: playerPosition)
        } else {
            let newPosition = movementStrategy.move(from: (x: characteristics.position.x, y: characteristics.position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
            characteristics.position = Position(newPosition.x, newPosition.y)
        }
        return characteristics.position
    }

    private func randomMove(in room: Room) -> Position {
        let possibleMoves = [
            Position(characteristics.position.x + 1, characteristics.position.y),
            Position(characteristics.position.x - 1, characteristics.position.y),
            Position(characteristics.position.x, characteristics.position.y + 1),
            Position(characteristics.position.x, characteristics.position.y - 1)
        ].filter { room.isValidPosition($0) }
        return possibleMoves.randomElement() ?? characteristics.position
    }
}

class Vampire: Enemy {
    private var isFirstHit = true
    
    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 60, health: 60, agility: 15, strength: 10)
        super.init(type: .vampire, characteristics: characteristics, hostility: 9, movementStrategy: RandomMovement())
    }

    override func attack(player: Player) -> AttackResult {
        if isFirstHit {
            isFirstHit = false
            return .miss // Первый удар всегда промах
        }
        let result = super.attack(player: player)
        if case .hit = result {
            player.characteristics.maxHealth -= 5 // Отнимает максимальное здоровье
            player.characteristics.health = min(player.characteristics.health, player.characteristics.maxHealth)
        }
        return result
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if shouldPursue(playerPosition: playerPosition) {
            return pursuePlayer(room: room, playerPosition: playerPosition)
        }
        let newPosition = movementStrategy.move(from: (x: characteristics.position.x, y: characteristics.position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
        characteristics.position = Position(newPosition.x, newPosition.y)
        return characteristics.position
    }
}

class Ghost: Enemy {

    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 40, health: 40, agility: 18, strength: 5)
        super.init(type: .ghost, characteristics: characteristics, hostility: 6, movementStrategy: TeleportMovement())
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if shouldPursue(playerPosition: playerPosition) {
            return pursuePlayer(room: room, playerPosition: playerPosition)
        }
        // Телепортация с шансом 30%
        if Int.random(in: 1...100) <= 30 {
            let newPosition = movementStrategy.move(from: (x: characteristics.position.x, y: characteristics.position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
            characteristics.position = Position(newPosition.x, newPosition.y)
            isVisible = Int.random(in: 1...100) > 20 // 80% шанс стать видимым после телепортации
            return characteristics.position
        }
        // Если не телепортировался, остается на месте и может стать невидимым
        isVisible = Int.random(in: 1...100) > 20
        return characteristics.position
    }
}

class Ogre: Enemy {

    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 120, health: 120, agility: 2, strength: 25)
        super.init(type: .ogre, characteristics: characteristics, hostility: 5, movementStrategy: RandomMovement())
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if isResting {
            isResting = false
            return characteristics.position
        }

        // Для преследования
        if shouldPursue(playerPosition: playerPosition) {
            let newPosition = pursuePlayer(room: room, playerPosition: playerPosition, step: 2)
            characteristics.position = newPosition
            return newPosition
        }

        // Для обычного движения (с шагом 2)
        let basePosition = super.move(in: room, playerPosition: playerPosition)
        let deltaX = basePosition.x - characteristics.position.x
        let deltaY = basePosition.y - characteristics.position.y
        let finalPosition = Position(
            characteristics.position.x + deltaX * 2,
            characteristics.position.y + deltaY * 2
        )

        characteristics.position = room.isValidPosition(finalPosition) ? finalPosition : basePosition
        return characteristics.position
    }

    override func attack(player: Player) -> AttackResult {
        let result = super.attack(player: player)
        isResting = true // Отдых после атаки
        return result
    }

    internal override func randomMove(in room: Room, step: Int) -> Position {
        let possibleMoves = [
            Position(characteristics.position.x + step, characteristics.position.y),
            Position(characteristics.position.x - step, characteristics.position.y),
            Position(characteristics.position.x, characteristics.position.y + step),
            Position(characteristics.position.x, characteristics.position.y - step)
        ].filter { room.isValidPosition($0) }
        return possibleMoves.randomElement() ?? characteristics.position
    }
}

class SnakeMage: Enemy {

    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 50, health: 50, agility: 20, strength: 8)
        super.init(type: .snakeMage, characteristics: characteristics, hostility: 8, movementStrategy: DiagonalMovement())
    }

    override func move(in room: Room, playerPosition: Position) -> Position {
        if shouldPursue(playerPosition: playerPosition) {
            return pursuePlayer(room: room, playerPosition: playerPosition)
        }
        let newPosition = movementStrategy.move(from: (x: characteristics.position.x, y: characteristics.position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
        characteristics.position = Position(newPosition.x, newPosition.y)
        // Если движение не удалось (например, стена), используем случайное движение
        if newPosition.x == characteristics.position.x && newPosition.y == characteristics.position.y {
            let fallback = RandomMovement()
            let fallbackPosition = fallback.move(from: (x: characteristics.position.x, y: characteristics.position.y), in: room, toward: (x: playerPosition.x, y: playerPosition.y))
            characteristics.position = Position(fallbackPosition.x, fallbackPosition.y)
        }
        return characteristics.position
    }

    override func attack(player: Player) -> AttackResult {
        let result = super.attack(player: player)
        if case .hit = result, Int.random(in: 1...100) <= 30 {
            player.isAsleep = true
        }
        return result
    }
}
