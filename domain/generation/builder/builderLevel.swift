//
//  builderLevel.swift
//  rogue

public struct LevelBuilder {
    
    static private var levelNumber: Int = 0
    
    static public func buildLevel(roomGenerator: RoomGeneratorProtocol = RoomGenerator(), corridorsGenerator: CorridorsGeneratorProtocol = CorridorsGenerator()) -> (Level, GameMap) {
        levelNumber += 1
        let rooms = roomGenerator.generateRooms()
        let gameMap = GameMap()
        let player = Player()
        addRoomsCoordToMap(rooms, gameMap)
        let (corridors, graph) = generateConnections(rooms, corridorsGenerator)
        addCoridorsCoordToMap(corridors, gameMap)
        corridorsGenerator.removeUnusedDoors(rooms, corridors)
        addDooorsCoordToMap(rooms, gameMap)
        let (exitPosition, items) = setupStartRoomAndExit(rooms, graph, gameMap, player)
        return (Level(rooms, corridors, exitPosition, player, items, self.levelNumber), gameMap)
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

    static private func setupStartRoomAndExit(_ rooms: [Room], _ graph: Graph, _ gameMap: GameMap, _ player: Player) -> (Position, [Position : ItemProtocol]) {
        var mutableGraph = graph
        let indexStart = Int.random(in: 0..<rooms.count)
        rooms[indexStart].setStartRoom()
        let startPosition = randomPositionOnRoom(rooms[indexStart], offset: Constants.doorOffset)

        player.characteristics.position = startPosition
        gameMap.removePosition(startPosition)

        let items = generateItems(in: rooms, excluding: indexStart, player: player)

        let occupiedPositions = Set(items.keys)
        let indexEnd = mutableGraph.bfs(from: indexStart) ?? (0..<rooms.count).filter { $0 != indexStart }.randomElement()!
        let exitPosition = findValidExitPosition(in: rooms[indexEnd], excluding: occupiedPositions)
        return (exitPosition, items)
    }
    
    static private func randomPositionOnRoom(_ room: Room, offset: Int) -> Position {
        return Position(Int.random(in: room.lowLeft.x + offset...room.topRight.x - offset),
                        Int.random(in: room.lowLeft.y + offset...room.topRight.y - offset))
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
    
    static private func generateItems(in rooms: [Room], excluding startIndex: Int, player: Player) -> [Position: ItemProtocol] {
        var items = [Position: ItemProtocol]()
        
        for (index, room) in rooms.enumerated() where index != startIndex {
            let itemCount = Int.random(in: 0...3)
            var roomPositions = Set<Position>()
            for _ in 0..<itemCount {
                guard let position = findEmptyPosition(in: room, excluding: roomPositions) else { continue }
                //ИСПАВИТЬ В ЗАВИСИМОСТИ ОТ СЛОЖНОСТИ И УРОВНЯ
                let item = ItemFactory.randomItem(for: .normal, player: player, level: self.levelNumber)
                items[position] = item
                roomPositions.insert(position)
            }
        }
        
        return items
    }
    
    static private func findEmptyPosition(in room: Room, excluding positions: Set<Position>) -> Position? {
        let maxAttempts = 10
        for _ in 0..<maxAttempts {
            let position = randomPositionOnRoom(room, offset: Constants.Item.offset)
            if !positions.contains(position) {
                return position
            }
        }
        return nil
    }
    
    static private func findValidExitPosition(in room: Room, excluding occupiedPositions: Set<Position>) -> Position {
        let maxAttempts = 50
        for _ in 0..<maxAttempts {
            let position = randomPositionOnRoom(room, offset: Constants.doorOffset)
            if !occupiedPositions.contains(position) {
                return position
            }
        }
        return randomPositionOnRoom(room, offset: Constants.doorOffset)
    }
}


