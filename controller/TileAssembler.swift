import domain
import presentation

public struct TileAssembler {
    public static func buildTiles(from level: Level) -> [DrawableObject] {
        var tiles: [DrawableObject] = []

        // Комнаты
        for room in level.rooms {
            for x in room.lowLeft.x...room.topRight.x {
                for y in room.lowLeft.y...room.topRight.y {
                    let char: Character = (x == room.lowLeft.x || x == room.topRight.x || y == room.lowLeft.y || y == room.topRight.y) ? "#" : "."
                    let tile = Tile(position: Position(x, y), char: char, isVisible: true, colorPair: 1)
                    tiles.append(tile)
                }
            }
        }

        // Коридоры
        for corridor in level.corridors {
            for pos in corridor.route {
                let tile = Tile(position: pos, char: "+", isVisible: true, colorPair: 1)
                tiles.append(tile)
            }
        }

        // Двери
        for room in level.rooms {
            for door in room.doors {
                let tile = Tile(position: door.position, char: "D", isVisible: true, colorPair: 3)
                tiles.append(tile)
            }
        }

        // Предметы
        for (pos, item) in level.items {
            let char: Character
            let color: Int
            switch item.type {
            case .food:     char = "f"; color = 1
            case .weapon:   char = "w"; color = 4
            case .scroll:   char = "s"; color = 4
            case .elixir:   char = "e"; color = 4
            case .treasure: char = "*"; color = 4
            }
            tiles.append(Tile(position: pos, char: char, isVisible: true, colorPair: color))
        }

        // Враги
        for enemy in level.enemies {
            let char = enemy.type.symbol
            tiles.append(Tile(position: enemy.characteristics.position, char: char, isVisible: true, colorPair: 2))
        }

        // Игрок
        let player = level.player
        tiles.append(Tile(position: player.characteristics.position, char: "@", isVisible: true, colorPair: 1))

        // Выход
        tiles.append(Tile(position: level.exitPosition, char: "E", isVisible: true, colorPair: 1))

        return tiles
    }
}
