//
//  tileAssembler.swift
//  rogue

import domain
import presentation

public struct TileAssembler {

    public static func buildTiles(from level: Level) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        tiles.append(contentsOf: buildRoomTiles(rooms: level.rooms))
        tiles.append(contentsOf: buildCorridorTiles(corridors: level.corridors))
        tiles.append(contentsOf: buildDoorTiles(rooms: level.rooms))
        tiles.append(contentsOf: buildItemTiles(items: level.items))
        tiles.append(buildExitTile(position: level.exitPosition))
        tiles.append(contentsOf: buildEnemyTiles(enemies: level.enemies))
        tiles.append(buildPlayerTile(player: level.player))

        return tiles
    }

    private static func buildRoomTiles(rooms: [Room]) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        for room in rooms {
            for x in room.lowLeft.x...room.topRight.x {
                for y in room.lowLeft.y...room.topRight.y {
                    let isWall = (x == room.lowLeft.x || x == room.topRight.x ||
                                 y == room.lowLeft.y || y == room.topRight.y)
                    let char: Character = isWall ? "#" : "."
                    tiles.append(Tile(posX: x, posY: y, char: char, isVisible: true, colorPair: 1))
                }
            }
        }
        return tiles
    }

    private static func buildCorridorTiles(corridors: [Corridor]) -> [DrawableObject] {
        var tiles = [DrawableObject]()
        for corridor in corridors {
            for pos in corridor.route {
                tiles.append(Tile(posX: pos.x, posY: pos.y, char: "+", isVisible: true, colorPair: 1))
            }
        }
        return tiles
    }

    private static func buildDoorTiles(rooms: [Room]) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        for room in rooms {
            for door in room.doors {
                let color = colorForDoor(door.color)
                tiles.append(Tile(posX: door.position.x,
                                  posY: door.position.y,
                                  char: "D",
                                  isVisible: true,
                                  colorPair: color))
            }
        }
        return tiles
    }

    private static func buildItemTiles(items: [Position: ItemProtocol]) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        for (pos, item) in items {
            let (char, color) = symbolAndColorForItem(item)
            tiles.append(Tile(posX: pos.x, posY: pos.y, char: char, isVisible: true, colorPair: color))
        }
        return tiles
    }

    private static func buildExitTile(position: Position) -> DrawableObject {
        return Tile(posX: position.x, posY: position.y, char: "E", isVisible: true, colorPair: 1)
    }

    private static func buildEnemyTiles(enemies: [Enemy]) -> [DrawableObject] {
        var tiles = [DrawableObject]()
        for enemy in enemies {
            let (char, color) = symbolAndColorForEnemy(enemy)
            tiles.append(Tile(posX: enemy.characteristics.position.x,
                              posY: enemy.characteristics.position.y,
                              char: char,
                              isVisible: enemy.isVisible,
                              colorPair: color))
        }
        return tiles
    }

    private static func buildPlayerTile(player: Player) -> DrawableObject {
        return Tile(posX: player.characteristics.position.x,
                    posY: player.characteristics.position.y,
                    char: "@",
                    isVisible: true,
                    colorPair: 1)
    }

    private static func colorForDoor(_ color: Color) -> Int {
        switch color {
        case .red: return 2
        case .green: return 6
        case .blue: return 5
        case .none: return 1
        }
    }

    private static func symbolAndColorForItem(_ item: ItemProtocol) -> (Character, Int) {
        switch item.type {
        case .food: return ("f", 1)
        case .weapon: return ("w", 4)
        case .scroll: return ("s", 4)
        case .elixir: return ("e", 4)
        case .treasure: return ("*", 4)
        case .key(let colorKey): return ("k", colorForDoor(colorKey))
        }
    }

    private static func symbolAndColorForEnemy(_ enemy: Enemy) -> (Character, Int) {
        switch enemy.type {
        case .zombie: return ("Z", 6)
        case .vampire: return ("V", 2)
        case .ghost: return ("G", 1)
        case .ogre: return ("O", 4)
        case .snakeMage: return ("S", 1)
        case .mimic: return ("M", 1)
        }
    }
}
