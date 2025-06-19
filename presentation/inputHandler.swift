//
//  inputHandler.swift
//  rogue
//
import Darwin.ncurses

public enum PlayerAction {
    case move(dx: Int, dy: Int)
    case exit
    case none
    case openWeapon
    case openFood
    case openElixir
    case openScroll
    case showStats
}

public struct InputHandler {
    public static func getAction() -> PlayerAction {
        let key = getch()

        switch key {
        case Int32(Character("w").asciiValue!): return .move(dx: -1, dy: 0)
        case Int32(Character("s").asciiValue!): return .move(dx: 1, dy: 0)
        case Int32(Character("a").asciiValue!): return .move(dx: 0, dy: -1)
        case Int32(Character("d").asciiValue!): return .move(dx: 0, dy: 1)
        case Int32(27): return .exit // Esc
        case Int32(Character("h").asciiValue!): return .openWeapon
        case Int32(Character("j").asciiValue!): return .openFood
        case Int32(Character("k").asciiValue!): return .openElixir
        case Int32(Character("e").asciiValue!): return .openScroll
        case Int32(Character("i").asciiValue!): return .showStats
        default: return .none
        }
    }
}
