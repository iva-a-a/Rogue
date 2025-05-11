//
//  map.swift
//  rogue

public protocol RoomGeneratorProtocol {
    func generateRooms() -> [Room]
    func generateRoomInSector(gridX: Int, gridY: Int, sector: Sector) -> Room
}

public protocol CorridorGeneratorProtocol {
    func connectTwoRooms(_ room1: Room, _ room2: Room, _ direction1: Direction, _ direction2: Direction) -> Corridor?
    func connectRoomsVertical(_ room1: Room, _ room2: Room) -> Corridor?
    func connectRoomsHorizontal(_ room1: Room, _ room2: Room) -> Corridor?
    
    func generateRandomCorridors(rooms: [Room]) -> (Graph, [Corridor])
    
    func availableIndexRooms(for indexRoom: Int) -> [Int]
    func isVerticalAvailable(_ fromRoom: Int, _ toRoom: Int) -> Bool
    
    func generateMissingDoors(_ rooms: [Room], _ indexFromRoom: Int, _ indexToRoom: Int, _ direction: Direction)
}

public class RoomGenerator: RoomGeneratorProtocol {
    
    public init() {}
    
    public func generateRoomInSector(gridX: Int, gridY: Int, sector: Sector) -> Room {
        let sectorTop = gridX * Constants.Grid.sectorHeight + Constants.indent
        let sectorBottom = (gridX + Constants.indent) * Constants.Grid.sectorHeight - 2 * Constants.indent
        let sectorLeft = gridY * Constants.Grid.sectorWidth + Constants.indent
        let sectorRight = (gridY + Constants.indent) * Constants.Grid.sectorWidth - 2 * Constants.indent
        
        let maxWidth = min(Constants.Room.maxWidth, sectorRight - sectorLeft + Constants.indent)
        let maxHeight = min(Constants.Room.maxHeight, sectorBottom - sectorTop + Constants.indent)
        let width = Int.random(in: Constants.Room.minWidth...maxWidth)
        let height = Int.random(in: Constants.Room.minHeight...maxHeight)
        
        let y1 = Int.random(in: sectorLeft...(sectorRight - width + Constants.indent))
        let x1 = Int.random(in: sectorTop...(sectorBottom - height + Constants.indent))
        let y2 = y1 + width - Constants.indent
        let x2 = x1 + height - Constants.indent
        
        return Room(Position(x2, y2), Position(x1, y1), sector)
    }
    
    public func generateRooms() -> [Room] {
        var rooms: [Room] = []
        var sectorIndex: Int = 0
        let sectors = Sector.allCases
        for i in 0..<Constants.Grid.size {
            for j in 0..<Constants.Grid.size {
                let sector = sectors[sectorIndex]
                rooms.append(generateRoomInSector(gridX: i, gridY: j, sector: sector))
                sectorIndex += 1
            }
        }
        return rooms
    }
    
    // Добавить удаление дверей
}

public class CorridorGenerator: CorridorGeneratorProtocol {
    
    public init() {}
    
    public func connectTwoRooms(_ room1: Room, _ room2: Room, _ direction1: Direction, _ direction2: Direction) -> Corridor? {
        guard
            let door1 = room1.doors.first(where: { $0.direction == direction1 }),
            let door2 = room2.doors.first(where: { $0.direction == direction2 })
        else {
            return nil
        }
        if direction1 == .right {
            return Corridor(from: Position(door1.position.x, door1.position.y + Constants.indent), to: Position(door2.position.x, door2.position.y - Constants.indent))
        }
        return Corridor(from: Position(door1.position.x + Constants.indent, door1.position.y), to: Position(door2.position.x - Constants.indent, door2.position.y))
    }
    
    public func connectRoomsVertical(_ room1: Room, _ room2: Room) -> Corridor? {
        return connectTwoRooms(room1, room2, .down, .up)
        
    }
    
    public func connectRoomsHorizontal(_ room1: Room, _ room2: Room) -> Corridor? {
        return connectTwoRooms(room1, room2, .right, .left)
    }
    
    public func generateRandomCorridors(rooms: [Room]) -> (Graph, [Corridor]) {
        var graph = Graph()
        var corridors : [Corridor] = []
        for i in 0..<9{
            if [0, 1, 3, 4, 6, 7].contains(i) {
                if let corridor1 = connectRoomsHorizontal(rooms[i], rooms[i + 1]) {
                    corridors.append(corridor1)
                    graph.addConnection(from: i, to: i + 1)
                }
            }
            if [0, 3, 1, 4, 2, 5].contains(i) {
                if let corridor2 = connectRoomsVertical(rooms[i], rooms[i + 3]) {
                    corridors.append(corridor2)
                    graph.addConnection(from: i, to: i + 3)
                }
            }
        }
        return (graph, corridors)
    }
    
    public func availableIndexRooms(for indexRoom: Int) -> [Int] {
        switch indexRoom {
        case 0: return [1, 3]
        case 1: return [0, 2, 4]
        case 2: return [1, 5]
        case 3: return [0, 4, 6]
        case 4: return [1, 3, 5, 7]
        case 5: return [2, 4, 8]
        case 6: return [3, 7]
        case 7: return [4, 6, 8]
        default: return [5, 7]
        }
    }
    
    public func generateMissingDoors(_ rooms: [Room], _ indexFromRoom: Int, _ indexToRoom: Int, _ direction: Direction) {
        if rooms[indexFromRoom].doors.first(where: { $0.direction == direction }) == nil {
            rooms[indexFromRoom].doors.append(rooms[indexFromRoom].createDoor(direction))
        }
        if rooms[indexToRoom].doors.first(where: { $0.direction == direction.opposite }) == nil {
            rooms[indexToRoom].doors.append(rooms[indexToRoom].createDoor(direction.opposite))
        }
    }
    
    public func isVerticalAvailable(_ fromRoom: Int, _ toRoom: Int) -> Bool {
        if fromRoom + 3 == toRoom {
            return true
        }
        return false
    }
}

public class Map {
    public var rooms: [Room] = []
    public var corridors: [Corridor] = []
    
    private let roomGenerator: RoomGeneratorProtocol
    private let corridorGenerator: CorridorGeneratorProtocol
    
    public init(roomGenerator: RoomGeneratorProtocol = RoomGenerator(), corridorGenerator: CorridorGeneratorProtocol = CorridorGenerator()) {
        self.roomGenerator = roomGenerator
        self.corridorGenerator = corridorGenerator
        self.generateMap()
    }
    
    private func generateMap() {
        self.rooms = roomGenerator.generateRooms()
        var (graph, newCorridors) = corridorGenerator.generateRandomCorridors(rooms: self.rooms)
        self.corridors = newCorridors
        graph.dfs(from: 0)
        while let disconnectedRoomIndex = graph.connectivity.firstIndex(where: { $0 == false }) {
            let roomToConnect = corridorGenerator.availableIndexRooms(for: disconnectedRoomIndex)[0]
            if corridorGenerator.isVerticalAvailable(roomToConnect, disconnectedRoomIndex) {
                corridorGenerator.generateMissingDoors(self.rooms, roomToConnect, disconnectedRoomIndex, .down)
                if let cor = corridorGenerator.connectRoomsVertical(rooms[roomToConnect], rooms[disconnectedRoomIndex]) {
                    corridors.append(cor)
                    graph.addConnection(from: roomToConnect, to: disconnectedRoomIndex)
                }
            } else {
                corridorGenerator.generateMissingDoors(self.rooms, roomToConnect, disconnectedRoomIndex, .right)
                if let cor = corridorGenerator.connectRoomsHorizontal(rooms[roomToConnect], rooms[disconnectedRoomIndex]) {
                    corridors.append(cor)
                    graph.addConnection(from: roomToConnect, to: disconnectedRoomIndex)
                }
            }
            graph.resetConnectivity()
            graph.dfs(from: 0)
            graph.printGraph()
        }
    }

    public func draw() {
        var grid = Array(repeating: Array(repeating: " ", count: Constants.Map.width), count: Constants.Map.height)
        
        for room in rooms {
            for x in room.lowLeft.x...room.topRight.x {
                for y in room.lowLeft.y...room.topRight.y {
                    if x == room.lowLeft.x || x == room.topRight.x || y == room.lowLeft.y || y == room.topRight.y {
                        grid[x][y] = "#"
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
        for row in grid {
            print(row.joined())
       }
    }

}
