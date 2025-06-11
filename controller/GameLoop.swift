import domain
import presentation
import Darwin.ncurses

public final class GameLoop {
    private let controller = Controller()
    private let renderer = LevelRenderer()

    public init() {}

    public func start() {
        configureCurses()

        controller.generateLevel()
        guard let level = controller.level else {
            print("Ошибка: уровень не сгенерирован")
            endwin()
            exit(1)
        }

        var isRunning = true

        while isRunning {
            clear()
            let tiles = TileAssembler.buildTiles(from: level)
            renderer.drawTiles(tiles)
            refresh()

            let action = InputHandler.getAction()

            switch action {
            case .move(let dx, let dy):
                let newX = level.player.characteristics.position.x + dx
                let newY = level.player.characteristics.position.y + dy
                let newPos = Position(newX, newY)

                if level.gameMap.isWalkable(newPos) {
                    // level.gameMap.rewrite(from: level.player.characteristics.position, to: newPos)
                    level.player.characteristics.position = newPos
                }

            case .exit:
                isRunning = false

            default:
                break
            }
        }

        endwin()
    }
}
