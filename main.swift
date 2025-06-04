import Foundation
import Darwin.ncurses

import controller
import presentation
import domain

let controller = Controller()
controller.generateLevel()

guard let level = controller.level else {
    exit(1)
}

let renderer = LevelRenderer()

// MARK: - ncurses setup
initscr()
raw()
noecho()
curs_set(0)
keypad(stdscr, true)
start_color()

var isRunning = true

while isRunning {
    clear()

    var tiles: [Tile] = []
    for room in level.rooms {
        for x in room.lowLeft.x...room.topRight.x {
            for y in room.lowLeft.y...room.topRight.y {
                let symbol: Character = (x == room.lowLeft.x || x == room.topRight.x || y == room.lowLeft.y || y == room.topRight.y) ? "#" : "."
                tiles.append(Tile(x: x, y: y, char: symbol, isVisible: true))
            }
        }
    }

    for corridor in level.corridors {
        for pos in corridor.route {
            tiles.append(Tile(x: pos.x, y: pos.y, char: "+", isVisible: true))
        }
    }

    renderer.drawTiles(tiles)

    let itemDrawables: [DrawableObject] = level.items.map {
        let char: Character
        switch $0.value.type {
        case .food: char = "f"
        case .weapon: char = "w"
        case .scroll: char = "s"
        case .elixir: char = "e"
        case .treasure: char = "*"
        }
        return DrawableObject(x: $0.key.x, y: $0.key.y, char: char)
    }
    renderer.drawItems(itemDrawables)

    let enemyDrawables = level.enemies.map {
        DrawableObject(x: $0.characteristics.position.x,
                       y: $0.characteristics.position.y,
                       char: $0.type.symbol)
    }
    renderer.drawObjects(enemyDrawables)

    let player = level.player
    let playerDrawable = DrawableObject(
        x: player.characteristics.position.x,
        y: player.characteristics.position.y,
        char: "@"
    )
    renderer.drawObjects([playerDrawable])

    renderer.drawExit(at: level.exitPosition)

    refresh()

    let action = InputHandler.getAction()

    switch action {
    case .move(let dx, let dy):
        let newX = player.characteristics.position.x + dx
        let newY = player.characteristics.position.y + dy
        let newPos = Position(newX, newY)

        // Проверка: не выйдет ли игрок за пределы уровня
        if level.gameMap.isWalkable(newPos) {            
            level.gameMap.rewrite(from: player.characteristics.position, to: newPos)
            player.characteristics.position = newPos
        }

    case .exit:
        isRunning = false

    default:
        break
    }
}

endwin()
