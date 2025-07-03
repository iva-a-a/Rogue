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
    
    public var coloredDoors: [Door] = []
    
    public var exploredPositions: Set<Position> = []


    public init(_ rooms: [Room],
                _ corridors: [Corridor],
                _ exitPosition: Position,
                _ player: Player,
                _ enemies: [Enemy],
                _ items: [Position: ItemProtocol],
                _ levelNumber: Int,
                _ gameMap: GameMap) {

        self.rooms = rooms
        self.corridors = corridors
        self.exitPosition = exitPosition
        self.player = player
        self.enemies = enemies
        self.items = items
        self.levelNumber = levelNumber
        self.gameMap = gameMap
        self.addColoredDoors()
    }
    
    private func defeatEnemy(_ enemy: Enemy) {
        if enemy.isDead {
            GameEventManager.shared.notify(.enemyDefeated(enemy: enemy.type.name))
            gameMap.addPosition(enemy.characteristics.position)
            self.dropTreasure(for: enemy)
            if let index = enemies.firstIndex(where: { $0 === enemy }) {
                enemies.remove(at: index)
            }
        }
    }

    public func dropWeapon() {
        guard player.weapon != nil else { return }
        let neighborPositions = findFreeNeighbor(around: player.characteristics.position)
        if neighborPositions == nil { return }
        GameEventManager.shared.notify(.weaponDropped(weapon: player.weapon!.type.name))
        let weapon = player.dropWeapon()
        self.items[neighborPositions!] = weapon
    }
    
    private func deleteItem(at: Position) {
        items.removeValue(forKey: at)
    }
    
    private func dropTreasure(for enemy: Enemy) {
        let treasureCount = Self.calculateTreasureCount(for: enemy)
        
        var positionsTried: Set<Position> = []
        var dropped = 0
        
        var attempts = 0
        let maxAttempts = 10
        while dropped < treasureCount, attempts < maxAttempts {
            let dropPosition = GetterPositions.randomPositionOnRoom(in: rooms[enemy.indexRoom], offset: 1)
            positionsTried.insert(dropPosition)
            if items[dropPosition] == nil {
                let treasure = ItemEntityFactory.createItem(of: .treasure, for: .normal,
                                                            player: player, level: levelNumber)
                items[dropPosition] = treasure
                dropped += 1
            }
            attempts += 1
        }
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
            self.attackEnemy(enemies[indexEnemy])
            return
        }
        guard tryOpenDoor(at: position) else { return }

        player.move(to: position, in: gameMap)
        if let item = items[position] {
            self.pickUpItem(item, at: position)
        }

        gameMap.updateVisibility(from: player.characteristics.position)
    }
    
    private func tryOpenDoor(at position: Position) -> Bool {
        guard let door = coloredDoors.first(where: { $0.position == position }) else {
            return true
        }
        
        if door.isUnlocked {
            return true
        }
        guard let keyIndex = findKeyIndex(for: door.color) else {
            GameEventManager.shared.notify(.notOpenColorDoor)
            return false
        }
        player.useItem(category: .key, index: keyIndex)
        door.isUnlocked = true
        GameEventManager.shared.notify(.openColorDoor(color: door.color.name))
        return true
        
    }
    
    private func findKeyIndex(for color: Color) -> Int? {
        guard let keys = player.backpack.items[.key] else {
            return nil
        }
        return keys.firstIndex(where: { item in
            if case let .key(itemColor) = item.type {
                return itemColor == color
            }
            return false
        })
    }

    private func attackEnemy(_ enemy: Enemy) {
        let result = player.attack(enemy)
        switch result {
        case .miss:
            GameEventManager.shared.notify(.playerMissed(target: enemy.type.name))
        case .hit(let damage):
            GameEventManager.shared.notify(.playerHit(target: enemy.type.name,
                                                      damage: damage,
                                                      remainingHealth: enemy.characteristics.health))
            defeatEnemy(enemy)
        }
    }
    
    private func pickUpItem(_ item: ItemProtocol, at position: Position) {
        let result = player.pickUpItem(item)
        if .success == result {
            deleteItem(at: position)
        }
    }
    
    public func enemiesTurn() {
        for enemy in enemies {
            let distance = abs(enemy.characteristics.position.x - player.characteristics.position.x) +
                         abs(enemy.characteristics.position.y - player.characteristics.position.y)
            if distance == 1 {
                let result = enemy.attack(player: player)
                switch result {
                case .miss:
                    GameEventManager.shared.notify(.enemyMissed(enemy: enemy.type.name))
                case .hit(let damage):
                    GameEventManager.shared.notify(.enemyHit(enemy: enemy.type.name, damage: damage))
                }
            } else {
                enemy.move(level: self)
            }
        }
    }
    
    private func addColoredDoors() {
        for room in rooms {
            for door in room.doors {
                if door.color != .none {
                    coloredDoors.append(door)
                }
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
}
