//
//  visibilityEngine.swift
//  rogue

import Foundation

public struct VisibilityEngine {

    public static func computeVisiblePositions(from origin: Position, in level: Level, radius: Int = 5) -> Set<Position> {
        var visible = Set<Position>()

        if let currentRoom = level.rooms.first(where: { $0.contains(origin) }) {
            if currentRoom.isWall(origin) {
                if let door = currentRoom.doors.first(where: { $0.position == origin }) {
                    handleWallPosition(at: origin, in: currentRoom, level: level, radius: getRadius(for: door.direction, in: currentRoom), visiblePositions: &visible)
                }
            } else {
                handleRoomInterior(room: currentRoom, visiblePositions: &visible)
            }
        } else {
            handleCorridorPosition(at: origin, in: level, radius: radius, visiblePositions: &visible)
        }
        return visible
    }

    private static func handleRoomInterior(room: Room, visiblePositions: inout Set<Position>) {
        for x in room.lowLeft.x...room.topRight.x {
            for y in room.lowLeft.y...room.topRight.y {
                visiblePositions.insert(Position(x, y))
            }
        }
    }

    private static func handleWallPosition(at position: Position, in room: Room, level: Level, radius: Int, visiblePositions: inout Set<Position>) {
        guard let door = room.doors.first(where: { $0.position == position }) else {
            return
        }

        let directionAngle = angle(for: door.direction)
        let viewAngle = Double.pi / 2.5
        let halfView = viewAngle / 2

        for dx in -radius...radius {
            for dy in -radius...radius {
                let target = Position(position.x + dx, position.y + dy)
                guard !visiblePositions.contains(target), target != position else { continue }
                guard room.contains(target) else { continue }
                let angleToTarget = angleBetween(position, and: target)
                let angleDiff = abs(normalizeAngle(angleToTarget - directionAngle))

                if angleDiff <= halfView {
                    visiblePositions.insert(target)
                }
            }
        }
    }

    private static func handleCorridorPosition(at position: Position, in level: Level, radius: Int, visiblePositions: inout Set<Position>) {
        for dx in -radius...radius {
            for dy in -radius...radius {
                let target = Position(position.x + dx, position.y + dy)
                guard !visiblePositions.contains(target) else { continue }
                if hasLineOfSight(from: position, to: target, in: level) {
                    visiblePositions.insert(target)
                }
            }
        }
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

    private static func angle(for direction: Direction) -> Double {
        switch direction {
        case .left: return 0
        case .right: return .pi
        case .up: return .pi / 2
        case .down: return -.pi / 2
        }
    }

    private static func angleBetween(_ p1: Position, and p2: Position) -> Double {
        let vectorX = Double(p2.x - p1.x)
        let vectorY = Double(p2.y - p1.y)
        return atan2(vectorX, vectorY)
    }

    private static func normalizeAngle(_ angle: Double) -> Double {
        var angle = angle
        while angle <= -.pi { angle += 2 * .pi }
        while angle > .pi { angle -= 2 * .pi }
        return angle
    }

    private static func isOpaque(at pos: Position, in level: Level) -> Bool {
        for room in level.rooms {
            if room.contains(pos) {
                let isWall = (pos.x == room.lowLeft.x || pos.x == room.topRight.x ||
                             pos.y == room.lowLeft.y || pos.y == room.topRight.y)
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

    private static func getRadius(for direction: Direction, in room: Room) -> Int {
        switch direction {
        case .left, .right: return room.height
        case .up, .down: return room.width
        }
    }
}
