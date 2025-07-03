import Foundation

public struct VisibilityEngine {
    public static func computeVisiblePositions(from origin: Position, in level: Level, radius: Int = 8) -> Set<Position> {
        var visible: Set<Position> = []

        for dx in -radius...radius {
            for dy in -radius...radius {
                let target = Position(origin.x + dx, origin.y + dy)                

                if hasLineOfSight(from: origin, to: target, in: level) {
                    visible.insert(target)
                }
            }
        }

        return visible
    }

    private static func hasLineOfSight(from: Position, to: Position, in level: Level) -> Bool {
        let line = bresenhamLine(from: from, to: to)

        for point in line {
            if point == to {
                return true
            }
            if isOpaque(at: point, in: level) {
                return false
            }
        }

        return true
    }

    private static func bresenhamLine(from start: Position, to end: Position) -> [Position] {
        var line: [Position] = []

        let dx = abs(end.x - start.x)
        let dy = -abs(end.y - start.y)
        let sx = start.x < end.x ? 1 : -1
        let sy = start.y < end.y ? 1 : -1

        var err = dx + dy
        var x = start.x
        var y = start.y

        while true {
            line.append(Position(x, y))
            if x == end.x && y == end.y { break }
            let e2 = 2 * err
            if e2 >= dy {
                err += dy
                x += sx
            }
            if e2 <= dx {
                err += dx
                y += sy
            }
        }

        return line
    }

   private static func isOpaque(at pos: Position, in level: Level) -> Bool {
    for room in level.rooms {
        if room.contains(pos) {
            let isWall = (
                pos.x == room.lowLeft.x || pos.x == room.topRight.x ||
                pos.y == room.lowLeft.y || pos.y == room.topRight.y
            )
            return isWall
        }
    }

    for corridor in level.corridors {
        if corridor.route.contains(pos) {
            return false
        }
    }

    if level.coloredDoors.contains(where: { $0.position == pos && !$0.isUnlocked }) {
        return true
    }

    return !level.gameMap.isWalkable(pos)
}
}
