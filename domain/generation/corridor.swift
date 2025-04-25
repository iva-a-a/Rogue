//
//  corridor.swift
//  rogue

public class Corridor {
    var route: [Position] = []

    init(from: Position, to: Position) {
        let type: Int = Int.random(in: 0..<4)
        switch type {
        case 0:
            generateVertical(from, toY: to.y)
        case 1:
            generateHorizontal(from, toX: to.x)
        case 2:
            generateLShaped(from, to)
        case 3:
            generateZShaped(from, to)
        default:
            generateLShaped(from, to)
        }

        if !route.contains(where: { $0.x == to.x && $0.y == to.y }) {
            route.append(to)
        }
    }

    func generateHorizontal(_ from: Position, toX: Int) {
        guard from.x != toX else { return }

        var x = from.x
        let step = x < toX ? 1 : -1
        while x != toX {
            route.append(Position(x, from.y))
            x += step
        }
    }

    func generateVertical(_ from: Position, toY: Int) {
        guard from.y != toY else { return }

        var y = from.y
        let step = y < toY ? 1 : -1
        while y != toY {
            route.append(Position(from.x, y))
            y += step
        }
    }

    // ДОБАВЛЯЕТСЯ ТОЧКА РАЗЛОМА
    func generateLShaped(_ from: Position, _ to: Position) {
        guard from != to else { return }

        if Bool.random() {
            // горизонтально ->вертикально
            generateHorizontal(from, toX: to.x)
            generateVertical(Position(to.x, from.y), toY: to.y)
        } else {
            // вертикально -> горизонтально
            generateVertical(from, toY: to.y)
            generateHorizontal(Position(from.x, to.y), toX: to.x)
        }
    }

    func generateZShaped(_ from: Position, _ to: Position) {
        guard from != to else { return }

        // Определяем направление движения
        let xDirection = from.x < to.x ? 1 : -1
        let yDirection = from.y < to.y ? 1 : -1

        // выбрать точку разлома линий
        let xDistance = abs(from.x - to.x)
        let yDistance = abs(from.y - to.y)
        let splitX = xDistance > 2 ? from.x + Int.random(in: 1..<xDistance) * xDirection : from.x + xDirection
        let splitY = yDistance > 2 ? from.y + Int.random(in: 1..<yDistance) * yDirection : from.y + yDirection

        if Bool.random() {
            // горизонтально -> вертикально -> горизонтально
            generateHorizontal(from, toX: splitX)
            generateVertical(Position(splitX, from.y), toY: splitY)
            generateHorizontal(Position(splitX, splitY), toX: to.x)
        } else {
            // вертикально -> горизонтально -> вертикально
            generateVertical(from, toY: splitY)
            generateHorizontal(Position(from.x, splitY), toX: splitX)
            generateVertical(Position(splitX, splitY), toY: to.y)
        }
    }
}

