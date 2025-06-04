import Foundation
import Darwin.ncurses

import domain


// MARK: - Примитивы

public struct DrawableObject {
    public let x: Int
    public let y: Int
    public let char: Character

    public init(x: Int, y: Int, char: Character) {
        self.x = x
        self.y = y
        self.char = char
    }

    public var position: Position {
        Position(x, y)
    }
}

public struct Tile {
    public let x: Int
    public let y: Int
    public let char: Character
    public let isVisible: Bool

    public init(x: Int, y: Int, char: Character, isVisible: Bool) {
        self.x = x
        self.y = y
        self.char = char
        self.isVisible = isVisible
    }
}

// MARK: - Рендерер

public class LevelRenderer {

    public init() {}

    public func drawTiles(_ tiles: [Tile]) {
        for tile in tiles where tile.isVisible {
            mvaddch(Int32(tile.y), Int32(tile.x), UInt32(tile.char.asciiValue ?? 32))
        }
    }

    public func drawObjects(_ objects: [DrawableObject]) {
        for object in objects {
            mvaddch(Int32(object.y), Int32(object.x), UInt32(object.char.asciiValue ?? 63))
        }
    }

    public func drawItems(_ items: [DrawableObject]) {
        drawObjects(items)
    }

    public func drawExit(at position: Position) {
        mvaddch(Int32(position.y), Int32(position.x), UInt32(Character("E").asciiValue ?? 69))
    }

    public func drawString(_ string: String, atY y: Int, x: Int) {
        move(Int32(y), Int32(x))
        addstr(string)
}
}
