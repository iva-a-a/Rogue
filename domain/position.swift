//
//  position.swift
//  rogue

public struct Position: Hashable, Equatable{
    public let x: Int
    public let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}
