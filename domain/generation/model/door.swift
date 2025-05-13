//
//  door.swift
//  rogue

public enum Direction: CaseIterable {
    case up, down, left, right

    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
}

struct Door {
    let position: Position
    let direction: Direction

    init(_ position: Position, _ direction: Direction) {
        self.position = position
        self.direction = direction
    }
}
