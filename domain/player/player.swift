//
//  player.swift
//  rogue

public class Player {
    //var backpack: Backpack!
    // характеристики
    var characteristics: Characteristics
    var isAsleep: Bool = false
    
    public init(characteristics: Characteristics) {
        self.characteristics = characteristics
    }
}

