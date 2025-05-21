//
//  builderLevel.swift
//  rogue

public struct LevelBuilder {
    static public func buildLevel(roomGenerator: RoomGeneratorProtocol = RoomGenerator(), corridorsGenerator: CorridorsGeneratorProtocol = CorridorsGenerator()) -> (Level, Map) {
        let rooms = roomGenerator.generateRooms()
        let map = Map()
        addRoomsCoordToMap(rooms, map)
        var (graph, newCorridors) = corridorsGenerator.generateRandomCorridors(rooms: rooms)
        var corridors = newCorridors
        graph.dfs(from: 0)
        while let disconnectedRoomIndex = graph.connectivity.firstIndex(where: { $0 == false }) {
            let roomToConnect = corridorsGenerator.availableIndexRooms(for: disconnectedRoomIndex)[0]
            var direction = Direction.right
            if corridorsGenerator.isVerticalAvailable(roomToConnect, disconnectedRoomIndex) {
                direction =  Direction.down
            }
            corridorsGenerator.generateMissingDoors(rooms, roomToConnect, disconnectedRoomIndex, direction)
            if let cor = corridorsGenerator.connectTwoRooms(rooms[roomToConnect], rooms[disconnectedRoomIndex], direction) {
                corridors.append(cor)
                graph.addConnection(from: roomToConnect, to: disconnectedRoomIndex)
            }
            graph.resetConnectivity()
            graph.dfs(from: 0)
        }
        addCoridorsCoordToMap(corridors, map)
        corridorsGenerator.removeUnusedDoors(rooms, corridors)
        addDooorsCoordToMap(rooms, map)
        return (Level(rooms, corridors, self.setRandomStartRoomAndExit(rooms, graph, map)), map)
    }

    static private func setRandomStartRoomAndExit(_ rooms: [Room], _ graph: Graph, _ map: Map) -> Position {
        var mutableGraph = graph
        let indexStart = Int.random(in: 0..<rooms.count)
        rooms[indexStart].setStartRoom()

        let indexEnd = mutableGraph.bfs(from: indexStart) ?? (0..<rooms.count).filter { $0 != indexStart }.randomElement()!
        return self.generateExit(rooms[indexEnd], map)
    }

    // временно, потом переделать
    static private func generateExit(_ room: Room, _ map: Map) -> Position {
        let exit = generateRandomPositionOnRoom(room)
        map.removePosition(exit)
        return exit
    }
    
    static private func generateRandomPositionOnRoom(_ room: Room) -> Position {
        return Position(Int.random(in: room.lowLeft.x + Constants.doorOffset...room.topRight.x - Constants.doorOffset),
                        Int.random(in: room.lowLeft.y + Constants.doorOffset...room.topRight.y - Constants.doorOffset))
    }
    
    static private func addRoomsCoordToMap(_ rooms: [Room], _ map: Map) {
        for room in rooms {
            map.addPositions(room.interiorPositions())
        }
    }
    
    static private func addCoridorsCoordToMap(_ coridors: [Corridor], _ map: Map) {
        for coridor in coridors {
            map.addPositions(coridor.route)
        }
    }
    
    static private func addDooorsCoordToMap(_ rooms: [Room], _ map: Map) {
        for room in rooms {
            for door in room.doors {
                map.addPosition(door.position)
            }
        }
    }
}


