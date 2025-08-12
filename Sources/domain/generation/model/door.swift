//
//  door.swift
//  rogue

public enum Direction: String, CaseIterable {
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

public enum Color: String {
    case red, green, blue, none
    
    var name: String {
        switch self {
        case .red: return "Red"
        case .green: return "Green"
        case .blue: return "Blue"
        case .none: return "None"
        }
    }
}

public class Door {
    public let position: Position
    public let direction: Direction
    public var color: Color
    public var isUnlocked: Bool
    
    public init(_ position: Position, _ direction: Direction, _ color: Color = .none, isUnlocked: Bool = true) {
        self.position = position
        self.direction = direction
        self.color = color
        self.isUnlocked = isUnlocked
    }
}
