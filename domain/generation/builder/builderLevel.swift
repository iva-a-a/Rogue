//
//  builderLevel.swift
//  rogue

public struct LevelBuilder {
    static public func buildLevel(roomGenerator: RoomGeneratorProtocol = RoomGenerator(), corridorsGenerator: CorridorsGeneratorProtocol = CorridorsGenerator()) -> (Level, GameMap) {
        let rooms = roomGenerator.generateRooms()
        let gameMap = GameMap()
        let player = Player()
        addRoomsCoordToMap(rooms, gameMap)
        let (corridors, graph) = generateConnections(rooms, corridorsGenerator)
        addCoridorsCoordToMap(corridors, gameMap)
        corridorsGenerator.removeUnusedDoors(rooms, corridors)
        addDooorsCoordToMap(rooms, gameMap)
        let exitPosition = setupStartRoomAndExit(rooms, graph, gameMap, player)
        return (Level(rooms, corridors, exitPosition, player), gameMap)
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

    static private func setupStartRoomAndExit(_ rooms: [Room], _ graph: Graph, _ gameMap: GameMap, _ player: Player) -> Position {
        var mutableGraph = graph
        let indexStart = Int.random(in: 0..<rooms.count)
        rooms[indexStart].setStartRoom()
        let startPosition = randomPositionOnRoom(rooms[indexStart])
        player.characteristics.position = startPosition
        gameMap.removePosition(startPosition)
        let indexEnd = mutableGraph.bfs(from: indexStart) ?? (0..<rooms.count).filter { $0 != indexStart }.randomElement()!
        let exitPosition = randomPositionOnRoom(rooms[indexEnd])
        return exitPosition
    }
    
    static private func randomPositionOnRoom(_ room: Room) -> Position {
        return Position(Int.random(in: room.lowLeft.x + Constants.doorOffset...room.topRight.x - Constants.doorOffset),
                        Int.random(in: room.lowLeft.y + Constants.doorOffset...room.topRight.y - Constants.doorOffset))
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


