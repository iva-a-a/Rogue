//
//  render.swift
//  rogue

import Darwin.ncurses

public class Render {
    public init() {}

    public func drawTiles(_ tiles: [DrawableObject]) {
        for tile in tiles where tile.isVisible {
            tile.draw()
        }
    }

    public func drawString(_ string: String, atY y: Int, atX x: Int) {
        move(Int32(y), Int32(x))
        addstr(string)
    }
}
