//
//  level.swift
//  rogue

public class Level {
    public var rooms: [Room] = []
    public var corridors: [Corridor] = []
    public var player: Player
    public var enemies: [Enemy] = []
    public var items: [Position: ItemProtocol] = [:]

    public let exitPosition: Position
    public var levelNumber: Int
    
    public var gameMap: GameMap

    public init(_ rooms: [Room], _ corridors: [Corridor], _ exitPosition: Position, _ player: Player, _ enemies: [Enemy],_ items: [Position: ItemProtocol], _ levelNumber: Int, _ gameMap: GameMap) {
        self.rooms = rooms
        self.corridors = corridors
        self.exitPosition = exitPosition
        self.player = player
        self.enemies = enemies
        self.items = items
        self.levelNumber = levelNumber
        self.gameMap = gameMap
        GameEventManager.shared.addObserver(GameLogger.shared)
    }
    
    public func defeatEnemy(_ enemy: Enemy) {
        if enemy.isDead, let index = enemies.firstIndex(where: { $0 === enemy }) {
            GameEventManager.shared.notify(.enemyDefeated(enemy: enemy.type.name))
            gameMap.addPosition(enemy.characteristics.position)
            let treasureCount = Self.calculateTreasureCount(for: enemy)
            
            var positionsTried: Set<Position> = []
            var dropped = 0
            
            var attempts = 0
            let maxAttempts = 10
            while dropped < treasureCount, attempts < maxAttempts {
                let dropPosition = GetterPositions.randomPositionOnRoom(in: rooms[enemy.indexRoom], offset: 1)
                positionsTried.insert(dropPosition)
                if items[dropPosition] == nil {
                    let treasure = TreasureFactory().createItem(for: .normal, player: player, level: levelNumber)
                    items[dropPosition] = treasure
                    dropped += 1
                }
                attempts += 1
            }
            enemies.remove(at: index)
        }
    }

    public func deleteItem(at: Position) {
        items.removeValue(forKey: at)
    }
    
    func dropWeapon() {
        let neighborPositions = findFreeNeighbor(around: player.characteristics.position)
        if neighborPositions == nil { return }
        GameEventManager.shared.notify(.weaponDropped(weapon: player.weapon!.type.name))
        let weapon = player.dropWeapon()
        self.items[neighborPositions!] = weapon
    }
    
    private static func calculateTreasureCount(for enemy: Enemy) -> Int {
        let hostilityFactor = Double(enemy.hostility) * 0.3
        let strengthFactor = Double(enemy.strength) * 0.25
        let agilityFactor = Double(enemy.agility) * 0.2
        let healthFactor = Double(enemy.characteristics.health) * 0.15

        let base = hostilityFactor + strengthFactor + agilityFactor + healthFactor
        let scaled = base / 10.0 // нормализация
        let randomFactor = Double.random(in: 0.8...1.2)

        return max(1, Int((scaled * randomFactor).rounded()))
    }
    
    private func findFreeNeighbor(around pos: Position) -> Position? {
        let neighbors = [
            Position(pos.x, pos.y - 1),
            Position(pos.x, pos.y + 1),
            Position(pos.x - 1, pos.y),
            Position(pos.x + 1, pos.y)
        ].filter { gameMap.isWalkable($0) && items[$0] == nil }

        return neighbors.randomElement()
    }

    public func playerTurn(_ dx: Int, _ dy: Int) {
        guard player.isAsleep == false else {
            player.isAsleep = false
            GameEventManager.shared.notify(.playerSkipMove)
            return
        }
        let position = shiftToPosition(dx, dy)
        if let indexEnemy = enemies.firstIndex(where: { $0.characteristics.position == position }) {
            let result = player.attack(enemies[indexEnemy])
            switch result {
            case .miss:
                GameEventManager.shared.notify(.playerMissed(target: enemies[indexEnemy].type.name))
            case .hit(let damage):
                enemies[indexEnemy].receiveDamage(damage)
                GameEventManager.shared.notify(.playerHit(target: enemies[indexEnemy].type.name, damage: damage))
                defeatEnemy(enemies[indexEnemy])
            }
            return
        }
        player.move(to: position, in: gameMap)
        GameEventManager.shared.notify(.playerMoved(to: position))
        if let item = items[position] {
            let result = player.pickUpItem(item)
            switch result {
                case .success:
                    GameEventManager.shared.notify(.itemPickedUp(item: item.type.name))
                    deleteItem(at: position)
                case .isFull:
                    GameEventManager.shared.notify(.NotPickedUp)
            }
        }
    }
    
    
    public func enemiesTurn() {
        for enemy in enemies {
            let distance = abs(enemy.characteristics.position.x - player.characteristics.position.x) +
                         abs(enemy.characteristics.position.y - player.characteristics.position.y)
            if distance == 1 {
                let result = enemy.attack(player)
                switch result {
                case .miss:
                    GameEventManager.shared.notify(.enemyMissed(enemy: enemy.type.name))
                case .hit(let damage):
                    GameEventManager.shared.notify(.enemyHit(enemy: enemy.type.name, damage: damage))
                    player.receiveDamage(damage)
                }
            } else {
                enemy.move(self)
            }
        }
    }
    
    public func isWin() -> Bool {
        return player.characteristics.position == exitPosition && levelNumber == Constants.Level.max
    }
    
    public func isLose() -> Bool {
        return player.isDead
    }
    
    public func isLevelFinished() -> Bool {
        return player.characteristics.position == exitPosition && levelNumber < Constants.Level.max
    }
    
    public func getItemsList(_ category: ItemCategory) -> [ItemProtocol] {
        return player.backpack.items[category] ?? []
    }
    
    private func shiftToPosition(_ dx: Int, _ dy: Int) -> Position {
        return Position(player.characteristics.position.x + dx, player.characteristics.position.y + dy)
    }

    // для проверки, убрать позже
    public func draw() {
        var grid = Array(repeating: Array(repeating: " ", count: Constants.Map.width), count: Constants.Map.height)

        for room in rooms {
            for x in room.lowLeft.x...room.topRight.x {
                for y in room.lowLeft.y...room.topRight.y {
                    if x == room.lowLeft.x || x == room.topRight.x || y == room.lowLeft.y || y == room.topRight.y {
                        grid[x][y] = "#"
                        if room.isStartRoom {
                            grid[x][y] = "@"
                        }
                    }
                }
            }
            for door in room.doors {
                switch door.direction {
                case .up: grid[door.position.x][door.position.y] = "^"
                case .left: grid[door.position.x][door.position.y] = "<"
                case .down: grid[door.position.x][door.position.y] = "v"
                case .right: grid[door.position.x][door.position.y] = ">"
                }
            }
        }

        for corridor in corridors {
            for position in corridor.route {
                if grid[position.x][position.y] == " " {
                    grid[position.x][position.y] = "."
                }
            }
        }

        grid[exitPosition.x][exitPosition.y] = "E"
    

        for (position, item) in items {
            let symbol: String
            switch item.type {
            case .food:
                symbol = "f"
            case .weapon:
                symbol = "w"
            case .scroll:
                symbol = "s"
            case .elixir:
                symbol = "e"
            case .treasure:
                symbol = "*"
            }
            grid[position.x][position.y] = symbol
        }

        for enemy in enemies {
            let symbol: String
            switch enemy.type {
            case .zombie:
                symbol = "Z"
            case .vampire:
                symbol = "V"
            case .ghost:
                symbol = "G"
            case .ogre:
                symbol = "O"
            case .snakeMage:
                symbol = "S"
            }
            grid[enemy.characteristics.position.x][enemy.characteristics.position.y] = symbol
        }

        grid[player.characteristics.position.x][player.characteristics.position.y] = "P"


        for row in grid {
            print(row.joined())
       }
        gameMap.printMap()
    }
}
