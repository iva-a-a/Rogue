//
//  gameMap.swift
//  rogue

public class GameMap {
    public var walkablePositions: Set<Position> = []
    
    public private(set) var visibleTiles: Set<Position> = []
    public private(set) var seenTiles: Set<Position> = []
    
    public init() { }
    
    public init(_ walkablePositions: Set<Position>, _ visibleTiles: Set<Position>, _ seenTiles: Set<Position>) {
        self.walkablePositions = walkablePositions
        self.visibleTiles = visibleTiles
        self.seenTiles = seenTiles
    }
    
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
        visibleTiles.removeAll()
        seenTiles.removeAll()
    }
    
    public func isWalkable(_ position: Position) -> Bool {
        return walkablePositions.contains(position)
    }
    
    public func rewrite(from oldPosition: Position, to newPosition: Position) {
        self.addPosition(oldPosition)
        self.removePosition(newPosition)
    }

    public func updateVisibility(from origin: Position, radius: Int = 5) {
        visibleTiles.removeAll()

        for dx in -radius...radius {
            for dy in -radius...radius {
                let target = Position(origin.x + dx, origin.y + dy)
                if isInBounds(target) {
                    let ray = traceRay(from: origin, to: target)
                    for point in ray {
                        visibleTiles.insert(point)
                        seenTiles.insert(point)
                        if !isWalkable(point) { break }
                    }
                }
            }
        }
    }

    private func isInBounds(_ pos: Position) -> Bool {
        return pos.x >= 0 && pos.y >= 0 && pos.x < Constants.Map.height && pos.y < Constants.Map.width
    }

    private func traceRay(from start: Position, to end: Position) -> [Position] {
        var points: [Position] = []
        let dx = abs(end.x - start.x)
        let dy = abs(end.y - start.y)

        var x = start.x
        var y = start.y
        let sx = start.x < end.x ? 1 : -1
        let sy = start.y < end.y ? 1 : -1
        var err = dx - dy

        while true {
            points.append(Position(x, y))
            if x == end.x && y == end.y { break }
            let e2 = 2 * err
            if e2 > -dy {
                err -= dy
                x += sx
            }
            if e2 < dx {
                err += dx
                y += sy
            }
        }

        return points
    }
}
