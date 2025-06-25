//
//  inputHandler.swift
//  rogue
//
import Darwin.ncurses

public enum PlayerAction: Equatable {
    case move(dx: Int, dy: Int)
    case exit
    case none
    case openWeapon
    case openFood
    case openElixir
    case openScroll
    case showStats
    case start
    case useItem(index: Int)
    case dropWeapon
    
    public static func ==(lhs: PlayerAction, rhs: PlayerAction) -> Bool {
        switch (lhs, rhs) {
        case (.move(let dx1, let dy1), .move(let dx2, let dy2)):
            return dx1 == dx2 && dy1 == dy2
        case (.exit, .exit): return true
        case (.none, .none): return true
        case (.openWeapon, .openWeapon): return true
        case (.openFood, .openFood): return true
        case (.openElixir, .openElixir): return true
        case (.openScroll, .openScroll): return true
        case (.showStats, .showStats): return true
        case (.start, .start): return true
        case (.useItem(let i1), .useItem(let i2)):
            return i1 == i2
        case (.dropWeapon, .dropWeapon): return true
        default: return false
        }
    }

}

public struct InputHandler {
    public static func getAction() -> PlayerAction {
        let key = getch()

        switch key {

        case Int32(Character("w").asciiValue!): return .move(dx: -1, dy: 0)
        case Int32(Character("s").asciiValue!): return .move(dx: 1, dy: 0)
        case Int32(Character("a").asciiValue!): return .move(dx: 0, dy: -1)
        case Int32(Character("d").asciiValue!): return .move(dx: 0, dy: 1)
        case Int32(Character("h").asciiValue!): return .openWeapon
        case Int32(Character("j").asciiValue!): return .openFood
        case Int32(Character("k").asciiValue!): return .openElixir
        case Int32(Character("e").asciiValue!): return .openScroll
        case Int32(Character("i").asciiValue!): return .showStats
        case 27: return .exit          // Esc
        case 10, 13: return .start     // Enter
        case Int32(UnicodeScalar("1").value)...Int32(UnicodeScalar("9").value):
            let index = Int(key - Int32(UnicodeScalar("1").value))
            return .useItem(index: index)
        case Int32(UnicodeScalar("0").value): return .dropWeapon
        default: return .none
            
        }
    }
}
