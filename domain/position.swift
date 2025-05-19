//
//  position.swift
//  rogue

public struct Position: Hashable, Equatable{
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}
