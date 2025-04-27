//
//  door.swift
//  rogue

enum Direction: CaseIterable {
    case up
    case down
    case left
    case right
}

struct Door {
    var position: Position
    var direction: Direction
    
    init(_ position: Position, _ direction: Direction) {
        self.position = position
        self.direction = direction
    }
}
