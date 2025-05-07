//
//  room.swift
//  rogue

typealias Position = (x: Int, y: Int)

class Room {
    var topRight: Position
    var lowLeft: Position
    
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
    var isVisited: Bool = false

    init(_ topRight: Position, _ lowLeft: Position, _ sector: Int) {
        self.topRight = topRight
        self.lowLeft = lowLeft
        generateRandomDoors(sector)
    }

    public func generateDoor(_ dir: Direction) -> Door {
        if dir == .up {
            return Door(Position(x: lowLeft.x, y: Int.random(in: (lowLeft.y + 2)...(topRight.y - 2))), .up)
        } else if dir == .down {
            return Door(Position(x: topRight.x, y: Int.random(in: (lowLeft.y + 2)...(topRight.y - 2))), .down)
        } else if dir == .left {
            return Door(Position(x: Int.random(in: (lowLeft.x + 2)...(topRight.x - 2)), y: lowLeft.y), .left)
        } else {
            return Door(Position(x: Int.random(in: (lowLeft.x + 2)...(topRight.x - 2)), y: topRight.y), .right)
        }
    }

    func generateRandomDoors(_ sector: Int) {
        let dir: [Direction] = randomDirection(getAcceptableDirection(for: sector), getDoorsCount(for: sector))
        for d in dir {
            doors.append(generateDoor(d))
        }
    }

    func getDoorsCount(for sector: Int) -> Int {
        switch sector {
        case 5: return Int.random(in: 1...4)
        case 2, 4, 6, 8: return Int.random(in: 1...3)
        default: return Int.random(in: 1...2)
        }
    }

    func getAcceptableDirection(for sector: Int) -> [Direction] {
        switch sector {
        case 1: return [.right, .down]
        case 2: return [.left, .down, .right]
        case 3: return [.left, .down]
        case 4: return [.up, .right, .down]
        case 6: return [.up, .left, .down]
        case 7: return [.up, .right]
        case 8: return [.up, .left, .right]
        case 9: return [.up, .left]
        default: return Direction.allCases
        }
    }
    
    func randomDirection(_ directions: [Direction], _ count: Int) -> [Direction] {
        var randomDir: [Direction] = directions
        while randomDir.count > count {
            randomDir.remove(at: Int.random(in: 0..<randomDir.count))
        }
        return randomDir
    }
    
    //    func isInsidePosition(_ position: Position) -> Bool {
    //        return position.x >= lowLeft.x && position.x <= topRight.x &&
    //        position.y >= lowLeft.y && position.y <= topRight.y
    //    }
    //
    //    func isInsideRoom(_ other: Room) -> Bool {
    //        return isInsidePosition(other.topRight) && isInsidePosition(other.lowLeft)
    //    }
        
    //    func intersectsRoom(_ other: Room) -> Bool {
    //        return !(
    //            topRight.x <= other.lowLeft.x ||
    //            lowLeft.x >= other.topRight.x ||
    //            topRight.y <= other.lowLeft.y ||
    //            lowLeft.y >= other.topRight.y
    //        )
    //    }
        
    
//    func getWidth() -> Int {
//        return topRight.x - lowLeft.x + 1
//    }
//    
//    func getHeight() -> Int {
//        return topRight.y - lowLeft.y + 1
//    }
//    
//    func setStartRoom() {
//        self.isStartRoom = true
//    }
//    
//    func setEndRoom() {
//        self.isEndRoom = true
//    }
//    
//    func setVisited() {
//        self.isVisited = true
//    }
}


