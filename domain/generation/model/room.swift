//
//  room.swift
//  rogue

public enum Sector: Int, CaseIterable {
    case topLeft = 1, topCenter, topRight
    case middleLeft, center, middleRight
    case bottomLeft, bottomCenter, bottomRight

    var maxDoorCount: Int {
        switch self {
        case .center: return 4
        case .topCenter, .middleLeft, .middleRight, .bottomCenter: return 3
        default: return 2
        }
    }

    var acceptableDirection: [Direction] {
        switch self {
        case .topLeft: return [.right, .down]
        case .topCenter: return [.left, .down, .right]
        case .topRight: return [.left, .down]
        case .middleLeft: return [.up, .right, .down]
        case .center: return Direction.allCases
        case .middleRight: return [.up, .left, .down]
        case .bottomLeft: return [.up, .right]
        case .bottomCenter: return [.up, .left, .right]
        case .bottomRight: return [.up, .left]
        }
    }
}

public class Room {
    public let topRight: Position
    public let lowLeft: Position

    public var doors: [Door] = []

    public var isStartRoom: Bool = false

    init(_ topRight: Position, _ lowLeft: Position, _ sector: Sector) {
        self.topRight = topRight
        self.lowLeft = lowLeft
        generateRandomDoors(sector)
    }
    
    public init(_ topRight: Position, _ lowLeft: Position, _ doors: [Door]) {
        self.topRight = topRight
        self.lowLeft = lowLeft
        self.doors = doors
    }

    private func randomDoorPosition(for direction: Direction) -> Position {
        switch direction {
        case .up, .down:
            let y = Int.random(in: (lowLeft.y + Constants.doorOffset)...(topRight.y - Constants.doorOffset))
            return Position(direction == .up ? lowLeft.x : topRight.x, y)
        case .left, .right:
            let x = Int.random(in: (lowLeft.x + Constants.doorOffset)...(topRight.x - Constants.doorOffset))
            return Position(x, direction == .left ? lowLeft.y : topRight.y)
        }
    }

    func createDoor(_ direction: Direction) -> Door {
        return Door(randomDoorPosition(for: direction), direction)
    }

   private func generateRandomDoors(_ sector: Sector) {
        let direction: [Direction] = randomDirection(sector.acceptableDirection, getDoorsCount(for: sector))
        for d in direction {
            doors.append(createDoor(d))
        }
    }

    private func getDoorsCount(for sector: Sector) -> Int {
        return Int.random(in: 1...sector.maxDoorCount)
    }

    private func randomDirection(_ directions: [Direction], _ count: Int) -> [Direction] {
        var randomDir: [Direction] = directions
        while randomDir.count > count {
            randomDir.remove(at: Int.random(in: 0..<randomDir.count))
        }
        return randomDir
    }

    func removeDoor(in direction: Direction) {
        doors.removeAll(where: { $0.direction == direction })
    }

    func setStartRoom() {
        self.isStartRoom = true
    }

    func isInsideRoom(_ point: Position) -> Bool {
        return point.x > lowLeft.x && point.x < topRight.x &&
                   point.y > lowLeft.y && point.y < topRight.y
    }

    public func interiorPositions() -> [Position] {
        var positions: [Position] = []
        guard topRight.x > lowLeft.x + 1 && topRight.y > lowLeft.y + 1 else {
            return positions
        }
        for x in lowLeft.x+1..<topRight.x {
            for y in lowLeft.y+1..<topRight.y {
                positions.append(Position(x, y))
            }
        }
        return positions
    }

    public func contains(_ pos: Position) -> Bool {
        return pos.x >= lowLeft.x && pos.x <= topRight.x &&
               pos.y >= lowLeft.y && pos.y <= topRight.y
    }
    
    public func isWall(_ pos: Position) -> Bool {
        guard self.contains(pos) else {
            return false
        }
        return (pos.x == lowLeft.x || pos.x == topRight.x || pos.y == lowLeft.y || pos.y == topRight.y)
    }
    
    public var width: Int {
        return topRight.x - lowLeft.x
    }
    
    public var height: Int {
        return topRight.y - lowLeft.y
    }
}
