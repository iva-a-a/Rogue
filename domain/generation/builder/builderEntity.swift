//
//  builderEntity.swift
//  rogue

public protocol EntityBuilderProtocol {
    func generateItems(in rooms: [Room],
                       excluding occupiedPositions: inout Set<Position>,
                       player: Player,
                       difficulty: GameDifficulty,
                       levelNumber: Int
    ) -> [Position : ItemProtocol]

    func generateEnemies(in rooms: [Room],
                         excluding occupiedPositions: Set<Position>,
                         player: Player,
                         difficulty: GameDifficulty,
                         gameMap: inout GameMap,
                         levelNumber: Int
    ) -> [Enemy]

    func generateColorDoorsKeys(in rooms: [Room],
                                startRoomIndex: Int,
                                player: Player,
                                difficulty: GameDifficulty,
                                graph: Graph,
                                excluding occupiedPositions: inout Set<Position>,
                                level: Int
    ) -> [Position: ItemProtocol]
}

public class EntityBuilder: EntityBuilderProtocol {
    
    public init() {}
    
    public func generateItems(in rooms: [Room],
                              excluding occupiedPositions: inout Set<Position>,
                              player: Player,
                              difficulty: GameDifficulty,
                              levelNumber: Int
    ) -> [Position : ItemProtocol] {

        let factory = ItemEntityFactory()
        let items = factory.generate(in: rooms, excluding: occupiedPositions, player: player,
                                     level: levelNumber, difficulty: difficulty)
        occupiedPositions.formUnion(items.keys)
        return items
    }
    
    public func generateEnemies(in rooms: [Room],
                                excluding occupiedPositions: Set<Position>,
                                player: Player,
                                difficulty: GameDifficulty,
                                gameMap: inout GameMap,
                                levelNumber: Int
    ) -> [Enemy] {
        
        let factory = EnemyEntityFactory()
        let enemiesWithPositions = factory.generate(in: rooms, excluding: occupiedPositions, player: player,
                                                    level: levelNumber, difficulty: difficulty)
        for position in enemiesWithPositions.keys {
            gameMap.removePosition(position)
        }
        let enemies = recordPosToEnemy(enemiesWithPositions)
        return enemies
    }
    
    public func generateColorDoorsKeys(in rooms: [Room],
                                       startRoomIndex: Int,
                                       player: Player,
                                       difficulty: GameDifficulty,
                                       graph: Graph,
                                       excluding occupiedPositions: inout Set<Position>,
                                       level: Int
    ) -> [Position: ItemProtocol] {
        
        var keys: [Position: ItemProtocol] = [:]
        var updatedGraph = graph
        var usedDoors = Set<ObjectIdentifier>()
        var doorCount: Int = 0
        
        while keys.count < GenerationConstants.countColorDoors && doorCount < GenerationConstants.countColorDoors {
            
            guard let (keyRoomIndex, keyRoom) = findRandomAccessibleRoom(updatedGraph, startRoomIndex, rooms) else {
                break
            }
            guard let (keyItem, keyPosition) = generateAndPlaceKey(in: keyRoom,
                                                                   startRoom: rooms[startRoomIndex],
                                                                   player: player,
                                                                   difficulty: difficulty,
                                                                   level: level,occupiedPositions: occupiedPositions
            ), case let .key(color) = keyItem.type else {
                continue
            }
            
            let isLockDoor = findAndLockDoor(for: keyRoomIndex,
                                             startRoomIndex: startRoomIndex,
                                             color: color,
                                             rooms: rooms,
                                             usedDoors: &usedDoors,
                                             graph: &updatedGraph)
            if isLockDoor == true {
                keys[keyPosition] = keyItem
                doorCount += 1
            } else {
                KeyFactory.usedColors.remove(color)
                keys.removeValue(forKey: keyPosition)
            }
        }
        occupiedPositions.formUnion(keys.keys)
        return keys
    }
    
    private func recordPosToEnemy(_ enemies: [Position : Enemy]) -> [Enemy] {
        return enemies.map { position, enemy in
            let enemyCopy = enemy
            enemyCopy.characteristics.position = position
            return enemyCopy
        }
    }
    
    private func findAccessibleRooms(_ graph: Graph, _ startRoomIndex: Int, _ rooms: [Room]) -> [(index: Int, room: Room)] {
        var tempGraph = graph
        tempGraph.dfs(from: startRoomIndex)
        return tempGraph.connectivity.enumerated()
            .filter { $0.element }
            .map { (index, _) in (index, rooms[index]) }
    }
    
    private func findRandomAccessibleRoom(_ graph: Graph, _ startRoomIndex: Int, _ rooms: [Room]) -> (index: Int, room: Room)? {
        let accessibleRooms = findAccessibleRooms(graph, startRoomIndex, rooms)
        return accessibleRooms.randomElement()
    }
    
    private func generateAndPlaceKey(in room: Room,
                                     startRoom: Room,
                                     player: Player,
                                     difficulty: GameDifficulty,
                                     level: Int,
                                     occupiedPositions: Set<Position>
    ) -> (item: ItemProtocol, position: Position)? {

        let keyItem = ItemEntityFactory.createItem(of: .key, for: difficulty, player: player, level: level)
        guard case .key(_) = keyItem.type else { return nil }

        let keyPosition = GetterPositions.make(
            in: [room],
            excluding: occupiedPositions,
            count: 1,
            offset: GenerationConstants.itemOffset
        ).first ?? GetterPositions.randomPositionOnRoom(in: startRoom, offset: GenerationConstants.itemOffset)
        
        return (keyItem, keyPosition)
    }
    
    private func findAndLockDoor(for keyRoomIndex: Int,
                                 startRoomIndex: Int,
                                 color: Color,
                                 rooms: [Room],
                                 usedDoors: inout Set<ObjectIdentifier>,
                                 graph: inout Graph
    ) -> Bool {
        
        for (roomIndex, room) in rooms.enumerated().shuffled() {
            if roomIndex == startRoomIndex || roomIndex == keyRoomIndex { continue }
            
            for door in room.doors.shuffled() {
                let doorId = ObjectIdentifier(door)
                if usedDoors.contains(doorId) { continue }
                
                if tryLockDoor(
                    door: door,
                    color: color,
                    roomIndex: roomIndex,
                    keyRoomIndex: keyRoomIndex,
                    startRoomIndex: startRoomIndex,
                    usedDoors: &usedDoors,
                    graph: &graph
                ) {
                    return true
                }
            }
        }
        return false
    }

    private func tryLockDoor(door: Door,
                             color: Color,
                             roomIndex: Int,
                             keyRoomIndex: Int,
                             startRoomIndex: Int,
                             usedDoors: inout Set<ObjectIdentifier>,
                             graph: inout Graph
    ) -> Bool {
        var testGraph = graph
        testGraph.removeAllConnections(for: roomIndex)
        
        testGraph.dfs(from: startRoomIndex)
        if testGraph.connectivity[keyRoomIndex] {
            door.color = color
            door.isUnlocked = false
            usedDoors.insert(ObjectIdentifier(door))
            graph = testGraph
            return true
        }
        return false
    }
}
