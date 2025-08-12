//
//  characteristics.swift
//  rogue

public struct Characteristics {
    public var position: Position
    public var maxHealth: Int
    public var health: Int
    public var agility: Int
    public var strength: Int
    
    public init(position: Position, maxHealth: Int, health: Int, agility: Int, strength: Int) {
        self.position = position
        self.maxHealth = maxHealth
        self.health = health
        self.agility = agility
        self.strength = strength
    }
}

