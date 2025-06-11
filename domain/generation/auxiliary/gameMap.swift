//
//  gameMap.swift
//  rogue


public class GameMap {
    var walkablePositions: Set<Position> = []
    private var staticWalkable: Set<Position> = [] 
    private var occupied: Set<Position> = [] 
    
    public func addWalkablePositions(_ positions: [Position]) {
        positions.forEach { staticWalkable.insert($0) }
    }

    public func addWalkablePosition(_ position: Position) {
        staticWalkable.insert(position)
    }

    public func clear() {
        staticWalkable.removeAll()
        occupied.removeAll()
    }

    // public func addPositions(_ positions: [Position]) {
    //     positions.forEach { walkablePositions.insert($0) }
    // }
    
    // public func addPosition(_ position: Position) {
    //     walkablePositions.insert(position)
    // }
    
    // public func removePosition(_ position: Position) {
    //     walkablePositions.remove(position)
    // }
    
    // public func clear() {
    //     walkablePositions.removeAll()
    // }
    
    // public func isWalkable(_ position: Position) -> Bool {
    //     return walkablePositions.contains(position)
    // }

    
    // public func rewrite(from oldPosition: Position, to newPosition: Position) {
    //     self.removePosition(oldPosition)
    //     self.addPosition(newPosition)
    // }

    public func isWalkable(_ position: Position) -> Bool {
        return staticWalkable.contains(position) && !occupied.contains(position)
    }

    public func rewrite(from oldPosition: Position, to newPosition: Position) {
        occupied.remove(oldPosition)
        occupied.insert(newPosition)
    }

     public func freePosition(_ position: Position) {
        occupied.remove(position)
    }

    
     public func printMap() {
        for y in 0..<Constants.Map.height {
            for x in 0..<Constants.Map.width {
                let pos = Position(x, y)
                if occupied.contains(pos) {
                    print("X", terminator: "")
                } else if staticWalkable.contains(pos) {
                    print(".", terminator: "")
                } else {
                    print(" ", terminator: "")
                }
            }
            print()
        }
    }
}


