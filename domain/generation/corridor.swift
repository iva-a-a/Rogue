//
//  corridor.swift
//  rogue

public class Corridor {
    var route: [Position] = []

    init(from: Position, to: Position) {
        generateZShaped(from, to)
        addEndPoint(to)
    }

    private func generateVertical(_ from: Position, toX: Int) {
        guard from.x != toX else { return }

        var x = from.x
        let step = x < toX ? 1 : -1
        while x != toX {
            route.append(Position(x, from.y))
            x += step
        }
    }

    private func generateHorizontal(_ from: Position, toY: Int) {
        guard from.y != toY else { return }

        var y = from.y
        let step = y < toY ? 1 : -1
        while y != toY {
            route.append(Position(from.x, y))
            y += step
        }
    }
    
    private func addEndPoint(_ point: Position) {
        if !route.contains(point) {
            route.append(point)
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
        let splitX = xDistance > 2 ? from.x + Int.random(in: 1..<xDistance) * xDirection : from.x
        let splitY = yDistance > 2 ? from.y + Int.random(in: 1..<yDistance) * yDirection : from.y

        if Bool.random() {
            // горизонтально -> вертикально -> горизонтально
            generateHorizontal(from, toY: splitY)
            generateVertical(Position(from.x, splitY), toX: to.x)
            generateHorizontal(Position(to.x, splitY), toY: to.y)
        } else {
            // вертикально -> горизонтально -> вертикально
            generateVertical(from, toX: splitX)
            generateHorizontal(Position(splitX, from.y), toY: to.y)
            generateVertical(Position(splitX, to.y), toX: to.x)
        }
    }
}

