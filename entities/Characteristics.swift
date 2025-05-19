import Foundation

struct Position: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}


struct Object {
    var coordinates: Position 
    var size: Position
}

enum StatType {
    case health 
    case agility 
    case strength
    case none
}

enum Direction {
    case forward 
    case back 
    case left 
    case right
    case diagonnalyForwardLeft 
    case diagonnalyForwardRight 
    case diagonnalyBackLeft 
    case diagonnalyBackRight 
    case stop
}

enum MonsterType {
    case zombie 
    case vampire 
    case ghost 
    case ogre 
    case snake 
    case none
}

enum HostilityType {
    case low 
    case average 
    case high
}

struct Buf {
    var statIncrease: Int
    var effectEnd: Date
}

struct Buffs {
    var maxHealth: [Buf] 
    var agility: [Buf] 
    var strength: [Buf] 
}