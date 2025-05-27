//
//  builderLevel.swift
//  rogue

public struct LevelBuilder {
    
    static private var levelNumber: Int = 0
    
    static public func buildLevel(roomGenerator: RoomGeneratorProtocol = RoomGenerator(), corridorsGenerator: CorridorsGeneratorProtocol = CorridorsGenerator(), difficulty: GameDifficulty = .normal) -> Level {
        levelNumber += 1
        let rooms = roomGenerator.generateRooms()
        let gameMap = GameMap()
        let player = Player()
        addRoomsCoordToMap(rooms, gameMap)
        let (corridors, graph) = generateConnections(rooms, corridorsGenerator)
        addCoridorsCoordToMap(corridors, gameMap)
        corridorsGenerator.removeUnusedDoors(rooms, corridors)
        addDooorsCoordToMap(rooms, gameMap)
        let (exitPosition, items) = setupStartRoomAndExit(rooms, graph, gameMap, player, difficulty)
        return Level(rooms, corridors, exitPosition, player, items, self.levelNumber, gameMap)
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

    static private func setupStartRoomAndExit(_ rooms: [Room], _ graph: Graph, _ gameMap: GameMap, _ player: Player, _ difficulty: GameDifficulty) -> (Position, [Position : ItemProtocol]) {
        var mutableGraph = graph
        let indexStart = Int.random(in: 0..<rooms.count)
        rooms[indexStart].setStartRoom()
        let startPosition = GetterPositions.randomPositionOnRoom(in: rooms[indexStart], offset: Constants.doorOffset)

        player.characteristics.position = startPosition
        gameMap.removePosition(startPosition)
        
        
        var occupiedPositions: Set<Position> = []
        let indexEnd = mutableGraph.bfs(from: indexStart) ?? (0..<rooms.count).filter { $0 != indexStart }.randomElement()!
        let exitPosition = GetterPositions.make(in: [rooms[indexEnd]], excluding: occupiedPositions, count: 1, offset: GenerationConstants.exitOffset)
        occupiedPositions = Set(exitPosition)
        
        
        let factory = ItemEntityFactory()
        let items = factory.generate(in: rooms, excluding: occupiedPositions, player: player, level: levelNumber, difficulty: difficulty)
        
        occupiedPositions.formUnion(items.keys)
        
        return (exitPosition.first!, items)
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
}
