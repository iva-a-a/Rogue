//
//  room.swift
//  rogue

struct Position: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

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
    let topRight: Position
    let lowLeft: Position
    
    var doors: [Door] = []
    // предметы в комнате
    // var items: [(item: Item, position: Position)] = []
    // враги в комнате
    // var enemies: [(enemy: Enemy, position: Position)] = []
    
    // положение игрока в комнате?
    //var player: Position?
    var isStartRoom: Bool = false
    var isEndRoom: Bool = false

    var exitPosition: Position?
    // var isVisited: Bool = false

    init(_ topRight: Position, _ lowLeft: Position, _ sector: Sector) {
        self.topRight = topRight
        self.lowLeft = lowLeft
        generateRandomDoors(sector)
    }

    func createDoor(_ dir: Direction) -> Door {
        if dir == .up {
            return Door(Position(lowLeft.x, Int.random(in: (lowLeft.y + Constants.stepForDoor)...(topRight.y - Constants.stepForDoor))), .up)
        } else if dir == .down {
            return Door(Position(topRight.x, Int.random(in: (lowLeft.y + Constants.stepForDoor)...(topRight.y - Constants.stepForDoor))), .down)
        } else if dir == .left {
            return Door(Position(Int.random(in: (lowLeft.x + Constants.stepForDoor)...(topRight.x - Constants.stepForDoor)), lowLeft.y), .left)
        } else {
            return Door(Position(Int.random(in: (lowLeft.x + Constants.stepForDoor)...(topRight.x - Constants.stepForDoor)), topRight.y), .right)
        }
    }

    func generateRandomDoors(_ sector: Sector) {
        let dir: [Direction] = randomDirection(sector.acceptableDirection, getDoorsCount(for: sector))
        for d in dir {
            doors.append(createDoor(d))
        }
    }

    func getDoorsCount(for sector: Sector) -> Int {
        return Int.random(in: 1...sector.maxDoorCount)
    }
    
    func randomDirection(_ directions: [Direction], _ count: Int) -> [Direction] {
        var randomDir: [Direction] = directions
        while randomDir.count > count {
            randomDir.remove(at: Int.random(in: 0..<randomDir.count))
        }
        return randomDir
    }
}


