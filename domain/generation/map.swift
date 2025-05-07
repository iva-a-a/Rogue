//
//  map.swift
//  rogue

struct Graph {
    var connections: [(Int, [Int])]
    var connectivity: [Bool]
    
    init() {
        self.connections = (0..<9).map { ($0, [Int]()) }
        self.connectivity = Array(repeating: false, count: 9)
    }
}
extension Graph {
    mutating func addConnection(from: Int, to: Int) {
        guard from >= 0 && from < 9, to >= 0 && to < 9 else { return }
        if !connections[from].1.contains(to) {
            connections[from].1.append(to)
            connections[to].1.append(from)
        }
    }
    
    func printGraph() {
        for (room, connect) in connections {
            let printRoom = room + 1
            let printConnect = connect.map { $0 + 1 }
            print("Комната \(printRoom) соединена с: \(printConnect)")
        }
        for i in connectivity {
            print(i)
        }
    }
    
    mutating func dfs(_ numberRoom: Int) {
        connectivity[numberRoom] = true
        for i in connections[numberRoom].1 {
            if !connectivity[i] {
                dfs(i)
            }
        }
    }
    
    mutating func resetConnectivity() {
        connectivity = Array(repeating: false, count: connectivity.count)
    }
}

public class Map {
    var rooms: [Room] = []
    var corridors: [Corridor] = []
    
    public init() {
        self.generateRooms()
        var graph = self.generateRandomCorridors()
        graph.dfs(0)
        graph.printGraph()
        while let disconnectedRoomIndex = graph.connectivity.firstIndex(where: { $0 == false }) {
            let roomToConnect = vailableRooms(for: disconnectedRoomIndex)[0]
            var fromDoor: Door?
            var toDoor: Door?
            if vailableConnectionVertical(roomToConnect, disconnectedRoomIndex) {
                if let existingDoor1 = rooms[roomToConnect].doors.first(where: { $0.direction == .down }) {
                    fromDoor = existingDoor1
                } else {
                    let newDoor1 = rooms[roomToConnect].generateDoor(.down)
                    rooms[roomToConnect].doors.append(newDoor1)
                    fromDoor = newDoor1
                }
                if let existingDoor2 = rooms[disconnectedRoomIndex].doors.first(where: { $0.direction == .up }) {
                    toDoor = existingDoor2
                } else {
                    let newDoor2 = rooms[disconnectedRoomIndex].generateDoor(.up)
                    rooms[disconnectedRoomIndex].doors.append(newDoor2)
                    toDoor = newDoor2
                }
                if let cor = connectRoomsVertical(rooms[roomToConnect], rooms[disconnectedRoomIndex]) {
                    corridors.append(cor)
                    graph.addConnection(from: roomToConnect, to: disconnectedRoomIndex)
                }
            } else {
                if let existingDoor1 = rooms[roomToConnect].doors.first(where: { $0.direction == .right }) {
                    fromDoor = existingDoor1
                } else {
                    let newDoor1 = rooms[roomToConnect].generateDoor(.right)
                    rooms[roomToConnect].doors.append(newDoor1)
                    fromDoor = newDoor1
                }
                if let existingDoor2 = rooms[disconnectedRoomIndex].doors.first(where: { $0.direction == .left }) {
                    toDoor = existingDoor2
                } else {
                    let newDoor2 = rooms[disconnectedRoomIndex].generateDoor(.left)
                    rooms[disconnectedRoomIndex].doors.append(newDoor2)
                    toDoor = newDoor2
                }
                if let cor = connectRoomsHorizontal(rooms[roomToConnect], rooms[disconnectedRoomIndex]) {
                    corridors.append(cor)
                    graph.addConnection(from: roomToConnect, to: disconnectedRoomIndex)
                }
            }
            graph.resetConnectivity()
            graph.dfs(0)
            graph.printGraph()
        }
        graph.printGraph()
    }
    
    func generateRoomInSector(gridX: Int, gridY: Int, sector: Int) -> Room {
        let sectorTop = gridX * Constants.sectorHeight + Constants.indent
        let sectorBottom = (gridX + Constants.indent) * Constants.sectorHeight - 2 * Constants.indent
        let sectorLeft = gridY * Constants.sectorWidth + Constants.indent
        let sectorRight = (gridY + Constants.indent) * Constants.sectorWidth - 2 * Constants.indent
        
        let maxWidth = min(Constants.maxWidthRoom, sectorRight - sectorLeft + Constants.indent)
        let maxHeight = min(Constants.maxHeightRoom, sectorBottom - sectorTop + Constants.indent)
        let width = Int.random(in: Constants.minWidthRoom...maxWidth)
        let height = Int.random(in: Constants.minHeightRoom...maxHeight)
        
        let y1 = Int.random(in: sectorLeft...(sectorRight - width + Constants.indent))
        let x1 = Int.random(in: sectorTop...(sectorBottom - height + Constants.indent))
        let y2 = y1 + width - Constants.indent
        let x2 = x1 + height - Constants.indent
        
        return Room((x2, y2), (x1, y1), sector)
    }
    
    func generateRooms() {
        var sector: Int = 1
        for i in 0..<Constants.gridSize {
            for j in 0..<Constants.gridSize {
                rooms.append(generateRoomInSector(gridX: i, gridY: j, sector: sector))
                sector += 1
            }
        }
    }
    
    func oppositeDirection(for direction: Direction) -> Direction {
        switch direction {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
    
    func vailableRooms(for indexRoom: Int) -> [Int] {
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
    
    func vailableConnectionVertical(_ fromRoom: Int, _ toRoom: Int) -> Bool {
        if fromRoom + 3 == toRoom {
            return true
        }
        return false
    }
    
    func connectTwoRooms(_ room1: Room, _ room2: Room, _ direction1: Direction, _ direction2: Direction) -> Corridor? {
        guard
            let door1 = room1.doors.first(where: { $0.direction == direction1 }),
            let door2 = room2.doors.first(where: { $0.direction == direction2 })
        else {
            return nil
        }
        if direction1 == .right {
            return Corridor(from: Position(x: door1.position.x, y: door1.position.y + Constants.indent), to: Position(x: door2.position.x, y: door2.position.y - Constants.indent))
        }
        return Corridor(from: Position(x: door1.position.x + Constants.indent, y: door1.position.y), to: Position(x: door2.position.x - Constants.indent, y: door2.position.y))
    }
    
    func connectRoomsVertical(_ room1: Room, _ room2: Room) -> Corridor? {
        return connectTwoRooms(room1, room2, .down, .up)
        
    }
    
    func connectRoomsHorizontal(_ room1: Room, _ room2: Room) -> Corridor? {
        return connectTwoRooms(room1, room2, .right, .left)
    }
    
    func generateRandomCorridors() -> Graph {
        var graph = Graph()
        for i in 0..<rooms.count {
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
        return graph
    }
    
    public func draw() {
        var grid = Array(repeating: Array(repeating: " ", count: Constants.widthMap), count: Constants.heightMap)
        
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
                case .down: grid[door.position.x][door.position.y] = "-"
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
