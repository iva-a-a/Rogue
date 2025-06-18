//
//  generateRoomCorr.swift
//  rogue


public protocol RoomBuilderProtocol {
    func buildRooms() -> [Room]
}

public protocol CorridorsBuilderProtocol {
    func connectTwoRooms(_ room1: Room, _ room2: Room, _ direction1: Direction) -> Corridor?
    func buildRandomCorridors(rooms: [Room]) -> (Graph, [Corridor])

    func availableIndexRooms(for indexRoom: Int) -> [Int]
    func isVerticalAvailable(_ fromRoom: Int, _ toRoom: Int) -> Bool

    func buildMissingDoors(_ rooms: [Room], _ indexFromRoom: Int, _ indexToRoom: Int, _ direction: Direction)
    func removeUnusedDoors(_ rooms: [Room], _ corridors: [Corridor])
}

public class RoomBuilder: RoomBuilderProtocol {

    public init() {}

    private func generateRoomInSector(gridX: Int, gridY: Int, sector: Sector) -> Room {
        let (sectorTop, sectorBottom, sectorLeft, sectorRight) = calculateSectorBounds(gridX, gridY)

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

    private func calculateSectorBounds(_ gridX: Int, _ gridY: Int) -> (top: Int, bottom: Int, left: Int, right: Int) {
        let top = gridX * Constants.Grid.height + Constants.indent
        let bottom = (gridX + Constants.indent) * Constants.Grid.height - 2 * Constants.indent
        let left = gridY * Constants.Grid.width + Constants.indent
        let right = (gridY + Constants.indent) * Constants.Grid.width - 2 * Constants.indent
        return (top, bottom, left, right)
    }

    public func buildRooms() -> [Room] {
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
}

public class CorridorsBuilder: CorridorsBuilderProtocol {

    public init() {}

    public func connectTwoRooms(_ room1: Room, _ room2: Room, _ directionFrom: Direction) -> Corridor? {
        guard
            let door1 = room1.doors.first(where: { $0.direction == directionFrom }),
            let door2 = room2.doors.first(where: { $0.direction == directionFrom.opposite })
        else {
            return nil
        }
        switch directionFrom {
        case .right: return Corridor(from: Position(door1.position.x, door1.position.y + Constants.indent),
                                     to: Position(door2.position.x, door2.position.y - Constants.indent))
        case .down: return Corridor(from: Position(door1.position.x + Constants.indent, door1.position.y),
                                    to: Position(door2.position.x - Constants.indent, door2.position.y))
        default: return nil
        }
    }

    public func buildRandomCorridors(rooms: [Room]) -> (Graph, [Corridor]) {
        let size = Constants.Grid.size
        var graph = Graph()
        var corridors: [Corridor] = []

        for row in 0..<size {
            for col in 0..<size {
                let index = row * size + col
                if col < size - 1 {
                    let right = index + 1
                    if let corridor = connectTwoRooms(rooms[index], rooms[right], .right) {
                        corridors.append(corridor)
                        graph.addConnection(from: index, to: right)
                    }
                }
                if row < size - 1 {
                    let down = index + size
                    if let corridor = connectTwoRooms(rooms[index], rooms[down], .down) {
                        corridors.append(corridor)
                        graph.addConnection(from: index, to: down)
                    }
                }
            }
        }

        return (graph, corridors)
    }

    public func availableIndexRooms(for index: Int) -> [Int] {
        let size = Constants.Grid.size
        let row = index / size
        let col = index % size
        var neighbors: [Int] = []

        if col > 0 { neighbors.append(index - 1) }
        if col < size - 1 { neighbors.append(index + 1) }
        if row > 0 { neighbors.append(index - size) }
        if row < size - 1 { neighbors.append(index + size) }

        return neighbors.sorted()
    }

    public func buildMissingDoors(_ rooms: [Room], _ indexFromRoom: Int, _ indexToRoom: Int, _ direction: Direction) {
        if rooms[indexFromRoom].doors.first(where: { $0.direction == direction }) == nil {
            rooms[indexFromRoom].doors.append(rooms[indexFromRoom].createDoor(direction))
        }
        if rooms[indexToRoom].doors.first(where: { $0.direction == direction.opposite }) == nil {
            rooms[indexToRoom].doors.append(rooms[indexToRoom].createDoor(direction.opposite))
        }
    }

    public func isVerticalAvailable(_ fromRoom: Int, _ toRoom: Int) -> Bool {
        return fromRoom + 3 == toRoom
    }

    private func getStartEndPositionCorridors(for corridors: [Corridor]) -> Set<Position> {
        var usedDoorPositions: Set<Position> = []
        for corridor in corridors {
            if let first = corridor.route.first {
                usedDoorPositions.insert(first)
            }
            if let last = corridor.route.last {
                usedDoorPositions.insert(last)
            }
        }
        return usedDoorPositions
    }

    private func adjacentPositionDoor(for door: Door) -> Position {
        switch door.direction {
        case .up: return Position(door.position.x - 1, door.position.y)
        case .down: return Position(door.position.x + 1, door.position.y)
        case .left: return Position(door.position.x, door.position.y - 1)
        case .right: return Position(door.position.x, door.position.y + 1)
        }
    }

    public func removeUnusedDoors(_ rooms: [Room], _ corridors: [Corridor]) {
        let usedDoorPosition = getStartEndPositionCorridors(for: corridors)
        for room in rooms {
            for door in room.doors {
                let adjacentPosition = self.adjacentPositionDoor(for: door)
                if !usedDoorPosition.contains(adjacentPosition) {
                    room.removeDoor(in: door.direction)
                }
            }
        }
    }
}
