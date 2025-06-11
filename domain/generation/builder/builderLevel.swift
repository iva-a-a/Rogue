//
//  builderLevel.swift
//  rogue

public struct LevelBuilder {
    
    static private var levelNumber: Int = 0
    
    static public func buildLevel(roomGenerator: RoomGeneratorProtocol = RoomGenerator(), corridorsGenerator: CorridorsGeneratorProtocol = CorridorsGenerator(), difficulty: GameDifficulty = .normal) -> Level {
        levelNumber += 1
        let rooms = roomGenerator.generateRooms()
        var gameMap = GameMap()
        let player = Player()
        addRoomsCoordToMap(rooms, gameMap)
        let (corridors, graph) = generateConnections(rooms, corridorsGenerator)
        addCoridorsCoordToMap(corridors, gameMap)
        corridorsGenerator.removeUnusedDoors(rooms, corridors)
        addDooorsCoordToMap(rooms, gameMap)
        let (exitPosition, items, enemies) = setupStartRoomAndExit(rooms, graph, &gameMap, player, difficulty)
        return Level(rooms, corridors, exitPosition, player, enemies, items, self.levelNumber, gameMap)
    }
    
    static private func generateConnections(_ rooms: [Room],
                                            _ generator: CorridorsGeneratorProtocol) -> ([Corridor], Graph) {
        var (graph, newCorridors) = generator.generateRandomCorridors(rooms: rooms)
        var corridors = newCorridors
        graph.dfs(from: 0)
        while let disconnectedRoomIndex = graph.connectivity.firstIndex(where: { $0 == false }) {
            let roomToConnect = generator.availableIndexRooms(for: disconnectedRoomIndex)[0]
            var direction = Direction.right
            if generator.isVerticalAvailable(roomToConnect, disconnectedRoomIndex) {
                direction =  Direction.down
            }
            generator.generateMissingDoors(rooms, roomToConnect, disconnectedRoomIndex, direction)
            if let cor = generator.connectTwoRooms(rooms[roomToConnect], rooms[disconnectedRoomIndex], direction) {
                corridors.append(cor)
                graph.addConnection(from: roomToConnect, to: disconnectedRoomIndex)
            }
            graph.resetConnectivity()
            graph.dfs(from: 0)
        }
        return (corridors, graph)
    }

    static private func setupStartRoomAndExit(_ rooms: [Room], _ graph: Graph, _ gameMap: inout GameMap, _ player: Player, _ difficulty: GameDifficulty) -> (Position, [Position : ItemProtocol], [Enemy]) {
        var mutableGraph = graph
        let indexStart = Int.random(in: 0..<rooms.count)
        rooms[indexStart].setStartRoom()
        let startPosition = GetterPositions.randomPositionOnRoom(in: rooms[indexStart], offset: Constants.doorOffset)

        player.characteristics.position = startPosition
        // gameMap.removePosition(startPosition)
        
        
        var occupiedPositions: Set<Position> = []
        let indexEnd = mutableGraph.bfs(from: indexStart) ?? (0..<rooms.count).filter { $0 != indexStart }.randomElement()!
        let exitPosition = GetterPositions.make(in: [rooms[indexEnd]], excluding: occupiedPositions, count: 1, offset: GenerationConstants.exitOffset)
        occupiedPositions = Set(exitPosition)
        
        let items = generateItems(rooms, &occupiedPositions, player, difficulty)
        
        let enemies = generateEnemies(rooms, occupiedPositions, player, difficulty, &gameMap)
        
        return (exitPosition.first!, items, enemies)
    }
    
    static private func generateItems(_ rooms: [Room], _ occupiedPositions: inout Set<Position>, _ player: Player, _ difficulty: GameDifficulty) -> [Position : ItemProtocol] {
        let factory = ItemEntityFactory()
        let items = factory.generate(in: rooms, excluding: occupiedPositions, player: player, level: levelNumber, difficulty: difficulty)
        occupiedPositions.formUnion(items.keys)
        return items
    }
    
    static private func generateEnemies(_ rooms: [Room], _ occupiedPositions: Set<Position>, _ player: Player, _ difficulty: GameDifficulty, _ gameMap: inout GameMap) -> [Enemy] {
        let factory = EnemyEntityFactory()
        let enemiesWithPositions = factory.generate(in: rooms, excluding: occupiedPositions, player: player, level: levelNumber, difficulty: difficulty)
        // for position in enemiesWithPositions.keys {
        //     gameMap.removePosition(position)
        // }
        let enemies = recordPosToEnemy(enemiesWithPositions)
        return enemies
    }
    
    static private func recordPosToEnemy(_ enemies: [Position : Enemy]) -> [Enemy] {
        return enemies.map { position, enemy in
            let enemyCopy = enemy
            enemyCopy.characteristics.position = position
            return enemyCopy
        }
    }

    static private func addRoomsCoordToMap(_ rooms: [Room], _ gameMap: GameMap) {
        rooms.forEach { gameMap.addWalkablePositions($0.interiorPositions()) }
    }
    
    static private func addCoridorsCoordToMap(_ corridors: [Corridor], _ gameMap: GameMap) {
        corridors.forEach { gameMap.addWalkablePositions($0.route) }
    }
    
    static private func addDooorsCoordToMap(_ rooms: [Room], _ gameMap: GameMap) {
        rooms.flatMap { $0.doors }.forEach { gameMap.addWalkablePosition($0.position) }
    }
}

public enum GenerationConstants {
    static let maxPositAttempts = 30
    static let maxExitAttempts = 50
    static let maxItemsPerRoom = 3
    static let itemOffset = 1
    static let exitOffset = 2
}
