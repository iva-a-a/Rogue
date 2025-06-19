import Foundation
import Darwin.ncurses
import domain

public protocol DrawableObject {
    var position: Position { get set }
    var char: Character { get set }
    var isVisible: Bool { get set }
    var colorPair: Int { get set }

    func draw()
}

public struct Tile: DrawableObject {
    public var position: Position
    public var char: Character
    public var isVisible: Bool
    public var colorPair: Int

    public init(position: Position, char: Character, isVisible: Bool = true, colorPair: Int = 1) {
        self.position = position
        self.char = char
        self.isVisible = isVisible
        self.colorPair = colorPair
    }

    public func draw() {
        guard isVisible else { return }
        attron(COLOR_PAIR(Int32(colorPair)))
        mvaddch(Int32(position.x), Int32(position.y), UInt32(char.asciiValue ?? 32))
        attroff(COLOR_PAIR(Int32(colorPair)))
    }
}
