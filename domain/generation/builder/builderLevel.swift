//
//  builderLevel.swift
//  rogue

public struct LevelBuilder {
    
    static private var levelNumber: Int = 0
    
    static public func buildLevel(roomBuilder: RoomBuilderProtocol = RoomBuilder(),
                                  corridorsBuilder: CorridorsBuilderProtocol = CorridorsBuilder(),
                                  player: Player,
                                  difficulty: GameDifficulty = .normal
    ) -> Level {

        levelNumber += 1
        var gameMap = GameMap()
        
        let rooms = roomBuilder.buildRooms()
        addRoomsCoordToMap(rooms, gameMap)

        let (corridors, graph) = buildCorridors(rooms, corridorsBuilder)
        addCoridorsCoordToMap(corridors, gameMap)
        corridorsBuilder.removeUnusedDoors(rooms, corridors)
        addDooorsCoordToMap(rooms, gameMap)
        let (exitPosition, items, enemies) = buildContent(rooms, graph, &gameMap, player, difficulty)
        return Level(rooms, corridors, exitPosition, player, enemies, items, self.levelNumber, gameMap)
    }
    
    static private func buildCorridors(_ rooms: [Room],
                                       _ generator: CorridorsBuilderProtocol
    ) -> ([Corridor], Graph) {
        var (graph, newCorridors) = generator.buildRandomCorridors(rooms: rooms)
        var corridors = newCorridors
        graph.dfs(from: 0)
        while let disconnectedRoomIndex = graph.connectivity.firstIndex(where: { $0 == false }) {
            let roomToConnect = generator.availableIndexRooms(for: disconnectedRoomIndex)[0]
            var direction = Direction.right
            if generator.isVerticalAvailable(roomToConnect, disconnectedRoomIndex) {
                direction =  Direction.down
            }
            generator.buildMissingDoors(rooms, roomToConnect, disconnectedRoomIndex, direction)
            if let cor = generator.connectTwoRooms(rooms[roomToConnect], rooms[disconnectedRoomIndex], direction) {
                corridors.append(cor)
                graph.addConnection(from: roomToConnect, to: disconnectedRoomIndex)
            }
            graph.resetConnectivity()
            graph.dfs(from: 0)
        }
        return (corridors, graph)
    }

    static private func buildContent(_ rooms: [Room],
                                     _ graph: Graph,
                                     _ gameMap: inout GameMap,
                                     _ player: Player,
                                     _ difficulty: GameDifficulty
    ) -> (Position, [Position : ItemProtocol], [Enemy]) {
        
        KeyFactory.usedColors = []
        
        var occupiedPositions: Set<Position> = []
        
        let (indexStart, _) = buildStart(rooms, &gameMap, player, &occupiedPositions)

        let exitPosition = buildExit(rooms, graph, indexStart, &occupiedPositions)

        let (items, enemies) = buildEntities(rooms, indexStart, player, difficulty,
                                             graph, &occupiedPositions, levelNumber, &gameMap)
        
        return (exitPosition, items, enemies)
    }

    static private func buildEntities(_ rooms: [Room],
                                      _ startRoomIndex: Int,
                                      _ player: Player,
                                      _ difficulty: GameDifficulty,
                                      _ graph: Graph,
                                      _ occupiedPositions: inout Set<Position>,
                                      _ levelNumber: Int,
                                      _ gameMap: inout GameMap
    ) -> (items: [Position: ItemProtocol], enemies: [Enemy]) {
        
        let entityBuilder: EntityBuilderProtocol = EntityBuilder()
        
        let keys = entityBuilder.generateColorDoorsKeys(in: rooms, startRoomIndex: startRoomIndex, player: player,
                                                        difficulty: difficulty,graph: graph, excluding: &occupiedPositions,
                                                        level: levelNumber)
        var items = entityBuilder.generateItems(in: rooms, excluding: &occupiedPositions, player: player, difficulty: difficulty,
                                                levelNumber: levelNumber)

        items.merge(keys) { current, _ in current }

        let enemies = entityBuilder.generateEnemies(in: rooms, excluding: occupiedPositions, player: player,
                                                    difficulty: difficulty, gameMap: &gameMap, levelNumber: levelNumber)
        
        return (items, enemies)
    }
    
    
    static private func buildStart(_ rooms: [Room],
                                   _ gameMap: inout GameMap,
                                   _ player: Player,
                                   _ occupiedPositions: inout Set<Position>
    ) -> (index: Int, position: Position) {
    
        let indexStart = Int.random(in: 0..<rooms.count)
        rooms[indexStart].setStartRoom()
        let startPosition = GetterPositions.randomPositionOnRoom(
            in: rooms[indexStart],
            offset: Constants.doorOffset
        )
        player.characteristics.position = startPosition
        gameMap.removePosition(startPosition)
        occupiedPositions.insert(startPosition)
        return (indexStart, startPosition)
    }

    static private func buildExit(_ rooms: [Room],
                                  _ graph: Graph,
                                  _ startRoomIndex: Int,
                                  _ occupiedPositions: inout Set<Position>
    ) -> Position {

        var mutableGraph = graph
        let indexEnd = mutableGraph.bfs(from: startRoomIndex) ??
            (0..<rooms.count).filter { $0 != startRoomIndex }.randomElement()!
        
        let exitPosition = GetterPositions.make(
            in: [rooms[indexEnd]],
            excluding: occupiedPositions,
            count: 1,
            offset: GenerationConstants.exitOffset
        ).first!
        
        occupiedPositions.insert(exitPosition)
        return exitPosition
    }

    static private func addRoomsCoordToMap(_ rooms: [Room], _ gameMap: GameMap) {
        rooms.forEach { gameMap.addPositions($0.interiorPositions()) }
    }
    
    static private func addCoridorsCoordToMap(_ corridors: [Corridor], _ gameMap: GameMap) {
        corridors.forEach { gameMap.addPositions($0.route) }
    }
    
    static private func addDooorsCoordToMap(_ rooms: [Room], _ gameMap: GameMap) {
        rooms.flatMap { $0.doors }.forEach { gameMap.addPosition($0.position) }
    }
}

public enum GenerationConstants {
    static let maxPositAttempts = 30
    static let maxExitAttempts = 50
    static let maxItemsPerRoom = 3
    static let itemOffset = 1
    static let exitOffset = 2
    static let countColorDoors = 3
}
