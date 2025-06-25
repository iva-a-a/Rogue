//
//  gameMap.swift
//  rogue

public class GameMap {
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
    
    public func clear() {
        walkablePositions.removeAll()
    }
    
    public func isWalkable(_ position: Position) -> Bool {
        return walkablePositions.contains(position)
    }
    
    public func rewrite(from oldPosition: Position, to newPosition: Position) {
        self.addPosition(oldPosition)
        self.removePosition(newPosition)
    }
}
