// enemyTypes.swift

class Zombie: Enemy {
    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 80, health: 80, agility: 3, strength: 12)
        super.init(
            type: .zombie,
            characteristics: characteristics,
            hostility: 7,
            movementStrategy: RandomMovement(),
            attackBehavior: DefaultAttack(),
            pursuitBehavior: DefaultPursuit()
        )
    }
}

class Vampire: Enemy {
    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 60, health: 60, agility: 15, strength: 10)
        super.init(
            type: .vampire,
            characteristics: characteristics,
            hostility: 9,
            movementStrategy: RandomMovement(),
            attackBehavior: FirstMissAttack(),
            pursuitBehavior: DefaultPursuit()
        )
    }

    override func attack(player: Player) -> AttackResult {
        let result = attackBehavior.attack(attacker: self, player: player)
        if case .hit = result {
            player.characteristics.maxHealth -= 5
            player.characteristics.health = min(player.characteristics.health, player.characteristics.maxHealth)
        }
        return result
    }
}

class Ghost: Enemy {
    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 40, health: 40, agility: 18, strength: 5)
        super.init(
            type: .ghost,
            characteristics: characteristics,
            hostility: 6,
            movementStrategy: TeleportMovement(),
            attackBehavior: DefaultAttack(),
            pursuitBehavior: DefaultPursuit()
        )
    }

    override func move(in room: Room, map: GameMap, playerPosition: Position) -> Position {
        if pursuitBehavior.shouldPursue(enemy: self, playerPosition: playerPosition) {
            let newPosition = pursuitBehavior.pursue(enemy: self, room: room, playerPosition: playerPosition, step: 1)
            if map.isWalkable(newPosition) {
                map.addPosition(characteristics.position)
                map.removePosition(newPosition)
                characteristics.position = newPosition
            }
            return characteristics.position
        }

        if Int.random(in: 1...100) <= 30 {
            let newPos = movementStrategy.move(from: (characteristics.position.x, characteristics.position.y), in: room, toward: (playerPosition.x, playerPosition.y))
            let target = Position(newPos.x, newPos.y)
            if map.isWalkable(target) {
                map.addPosition(characteristics.position)
                map.removePosition(target)
                characteristics.position = target
            }
            isVisible = Int.random(in: 1...100) > 20
            return characteristics.position
        }

        isVisible = Int.random(in: 1...100) > 20
        return characteristics.position
    }
}

class Ogre: Enemy {
    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 120, health: 120, agility: 2, strength: 25)
        super.init(
            type: .ogre,
            characteristics: characteristics,
            hostility: 5,
            movementStrategy: RandomMovement(),
            attackBehavior: DefaultAttack(),
            pursuitBehavior: DefaultPursuit()
        )
    }

    override func move(in room: Room, map: GameMap, playerPosition: Position) -> Position {
        if isResting {
            isResting = false
            return characteristics.position
        }

        if pursuitBehavior.shouldPursue(enemy: self, playerPosition: playerPosition) {
            let newPosition = pursuitBehavior.pursue(enemy: self, room: room, playerPosition: playerPosition, step: 2)
            if map.isWalkable(newPosition) {
                map.addPosition(characteristics.position)
                map.removePosition(newPosition)
                characteristics.position = newPosition
            }
            return characteristics.position
        }

        let basePosition = randomMove(in: room, step: 1)
        let dx = basePosition.x - characteristics.position.x
        let dy = basePosition.y - characteristics.position.y
        let doubleStep = Position(characteristics.position.x + dx * 2, characteristics.position.y + dy * 2)

        if room.isValidPosition(doubleStep), map.isWalkable(doubleStep) {
            map.addPosition(characteristics.position)
            map.removePosition(doubleStep)
            characteristics.position = doubleStep
        } else if basePosition != characteristics.position, map.isWalkable(basePosition) {
            map.addPosition(characteristics.position)
            map.removePosition(basePosition)
            characteristics.position = basePosition
        }

        return characteristics.position
    }

    override func attack(player: Player) -> AttackResult {
        let result = attackBehavior.attack(attacker: self, player: player)
        isResting = true
        return result
    }

    override func randomMove(in room: Room, step: Int) -> Position {
        let options = [
            Position(characteristics.position.x + step, characteristics.position.y),
            Position(characteristics.position.x - step, characteristics.position.y),
            Position(characteristics.position.x, characteristics.position.y + step),
            Position(characteristics.position.x, characteristics.position.y - step)
        ].filter { room.isValidPosition($0) }
        return options.randomElement() ?? characteristics.position
    }
}

class SnakeMage: Enemy {
    init(position: Position) {
        let characteristics = Characteristics(position: position, maxHealth: 50, health: 50, agility: 20, strength: 8)
        super.init(
            type: .snakeMage,
            characteristics: characteristics,
            hostility: 8,
            movementStrategy: DiagonalMovement(),
            attackBehavior: DefaultAttack(),
            pursuitBehavior: DefaultPursuit()
        )
    }

    override func move(in room: Room, map: GameMap, playerPosition: Position) -> Position {
        if pursuitBehavior.shouldPursue(enemy: self, playerPosition: playerPosition) {
            let newPosition = pursuitBehavior.pursue(enemy: self, room: room, playerPosition: playerPosition, step: 1)
            if map.isWalkable(newPosition) {
                map.addPosition(characteristics.position)
                map.removePosition(newPosition)
                characteristics.position = newPosition
            }
            return characteristics.position
        }

        let attempt = movementStrategy.move(from: (characteristics.position.x, characteristics.position.y), in: room, toward: (playerPosition.x, playerPosition.y))
        let moved = Position(attempt.x, attempt.y)

        if moved != characteristics.position, map.isWalkable(moved) {
            map.addPosition(characteristics.position)
            map.removePosition(moved)
            characteristics.position = moved
            return moved
        }

        let fallback = RandomMovement()
        let fallbackMove = fallback.move(from: (characteristics.position.x, characteristics.position.y), in: room, toward: (playerPosition.x, playerPosition.y))
        let fallbackPosition = Position(fallbackMove.x, fallbackMove.y)
        if map.isWalkable(fallbackPosition) {
            map.addPosition(characteristics.position)
            map.removePosition(fallbackPosition)
            characteristics.position = fallbackPosition
        }
        return characteristics.position
    }

    override func attack(player: Player) -> AttackResult {
        let result = attackBehavior.attack(attacker: self, player: player)
        if case .hit = result, Int.random(in: 1...100) <= 30 {
            player.isAsleep = true
        }
        return result
    }
}
