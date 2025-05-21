//
//  map.swift
//  rogue


public class Map {
    var walkablePositions: Set<Position> = []
    
    public func addPositions(_ positions: [Position]) {
        positions.forEach { walkablePositions.insert($0) }
    }
    
    public func addPosition(_ position: Position) {
        walkablePositions.insert(position)
    }
    
    public func removePosition(_ position: Position) {
        walkablePositions.remove(position)
    }
    
    public func isWalkable(_ position: Position) -> Bool {
        return walkablePositions.contains(position)
    }
    
    public func printMap() {
        for x in 0..<Constants.Map.height {
            for y in 0..<Constants.Map.width {
                let pos = Position(x, y)
                if isWalkable(pos) {
                    print(".", terminator: "")
                } else {
                    print(" ", terminator: "")
                }
            }
            print()
            }
        }
    }


