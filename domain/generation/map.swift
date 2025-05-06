//
//  map.swift
//  rogue

public class Map {
    var rooms: [Room] = []
    var corridors: [Corridor] = []

    public init() {
        self.generateMap()
        self.generateCorridors()
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
    
    func generateMap() {
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
    
    func generateCorridors() {
        for i in 0..<rooms.count {
            if i == 0 || i == 1 || i == 3 || i == 4 || i == 6 || i == 7 {
                if let corridor1 = connectRoomsHorizontal(rooms[i], rooms[i + 1]) {
                    corridors.append(corridor1)
                }
            }
            if i == 0 || i == 3 || i == 1 || i == 4 || i == 2 || i == 5 {
                if let corridor2 = connectRoomsVertical(rooms[i], rooms[i + 3]) {
                    corridors.append(corridor2)
                }
            }
        }
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
