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

    public init() {
        self.posX = 0
        self.posY = 0
        self.char = " "
        self.isVisible = true
        self.colorPair = 1
    }

    public func draw() {
        guard isVisible else { return }
        attron(COLOR_PAIR(Int32(colorPair)))
        mvaddch(Int32(posX), Int32(posY), UInt32(char.asciiValue ?? 32))
        attroff(COLOR_PAIR(Int32(colorPair)))
    }
}

extension Tile {
    public func getDrawableObjectsFromString(str: String, x: Int, y: Int) -> [DrawableObject] {
        var result = [DrawableObject]()
        var thisX = x

        for char in str {
            result.append(Tile(posX: y, posY: thisX, char: char))
            thisX += 1
        }
        return result
    }
}
