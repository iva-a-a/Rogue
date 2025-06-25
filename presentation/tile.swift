//
//  tile.swift
//  rogue

import Darwin.ncurses

public protocol DrawableObject {
    var posX: Int { get set }
    var posY: Int { get set }
    var char: Character { get set }
    var isVisible: Bool { get set }
    var colorPair: Int { get set }

    func draw()
}

public struct Tile: DrawableObject {
    public var posX: Int
    public var posY: Int
    public var char: Character
    public var isVisible: Bool
    public var colorPair: Int

    public init(posX: Int, posY: Int, char: Character, isVisible: Bool = true, colorPair: Int = 1) {
        self.posX = posX
        self.posY = posY
        self.char = char
        self.isVisible = isVisible
        self.colorPair = colorPair
    }

    public func draw() {
        guard isVisible else { return }
        attron(COLOR_PAIR(Int32(colorPair)))
        mvaddch(Int32(posX), Int32(posY), UInt32(char.asciiValue ?? 32))
        attroff(COLOR_PAIR(Int32(colorPair)))
    }
}
