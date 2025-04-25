//
//  room.swift
//  rogue

typealias Position = (x: Int, y: Int)

class Room {
    var topRight: Position
    var lowLeft: Position
    
    // var doors: [Position] = []
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
    
    init(_ topRight: Position, _ lowLeft: Position/*, doors: [Position]*/) {
        self.topRight = topRight
        self.lowLeft = lowLeft
       // self.doors = doors
    }
    
    func isInsidePosition(_ position: Position) -> Bool {
        return position.x >= lowLeft.x && position.x <= topRight.x &&
        position.y >= lowLeft.y && position.y <= topRight.y
    }
    
    func isInsideRoom(_ other: Room) -> Bool {
        return isInsidePosition(other.topRight) && isInsidePosition(other.lowLeft)
    }
    
    func intersectsRoom(_ other: Room) -> Bool {
        return !(
            topRight.x <= other.lowLeft.x ||
            lowLeft.x >= other.topRight.x ||
            topRight.y <= other.lowLeft.y ||
            lowLeft.y >= other.topRight.y
        )
    }
    
    func getWidth() -> Int {
        return topRight.x - lowLeft.x + 1
    }
    
    func getHeight() -> Int {
        return topRight.y - lowLeft.y + 1
    }
    
    func setStartRoom() {
        self.isStartRoom = true
    }
    
    func setEndRoom() {
        self.isEndRoom = true
    }
    
    func setVisited() {
        self.isVisited = true
    }
}


