//
//  tileAssembler.swift
//  rogue

import domain
import presentation

public struct TileAssembler {

    public static func buildTiles(from level: Level, visiblePositions: Set<Position>, exploredPositions: Set<Position>) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        tiles.append(contentsOf: buildRoomTiles(rooms: level.rooms, visiblePositions: visiblePositions, exploredPositions: exploredPositions))
        tiles.append(contentsOf: buildCorridorTiles(corridors: level.corridors, visiblePositions: visiblePositions))
        tiles.append(contentsOf: buildDoorTiles(rooms: level.rooms, visiblePositions: visiblePositions))
        tiles.append(contentsOf: buildItemTiles(items: level.items, visiblePositions: visiblePositions))

        if visiblePositions.contains(level.exitPosition) {
            tiles.append(buildExitTile(position: level.exitPosition))
        }

        tiles.append(contentsOf: buildEnemyTiles(enemies: level.enemies, visiblePositions: visiblePositions))
        tiles.append(buildPlayerTile(player: level.player))

        return tiles
    }

   private static func buildRoomTiles(rooms: [Room], visiblePositions: Set<Position>, exploredPositions: Set<Position>) -> [DrawableObject] {
    var tiles = [DrawableObject]()

    for room in rooms {
        for x in room.lowLeft.x...room.topRight.x {
            for y in room.lowLeft.y...room.topRight.y {
                let pos = Position(x, y)
                let isWall = (x == room.lowLeft.x || x == room.topRight.x ||
                              y == room.lowLeft.y || y == room.topRight.y)
                
                if visiblePositions.contains(pos) {                    
                    let char: Character = isWall ? "#" : "."
                    tiles.append(Tile(posX: x, posY: y, char: char, isVisible: true, colorPair: ColorCode.white))
                } else if exploredPositions.contains(pos) && isWall {
                    tiles.append(Tile(posX: x, posY: y, char: "#", isVisible: true, colorPair: ColorCode.gray))
                }
            }
        }
    }

    return tiles
}



    private static func buildCorridorTiles(corridors: [Corridor], visiblePositions: Set<Position>) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        for corridor in corridors {
            for pos in corridor.route {
                if visiblePositions.contains(pos) {
                    tiles.append(Tile(posX: pos.x, posY: pos.y, char: "+", isVisible: true, colorPair: ColorCode.white))
                }
            }
        }

        return tiles
    }

    private static func buildDoorTiles(rooms: [Room], visiblePositions: Set<Position>) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        for room in rooms {
            for door in room.doors {
                let pos = door.position
                if visiblePositions.contains(pos) {
                    let color = colorForDoor(door.color)
                    tiles.append(Tile(posX: pos.x,
                                      posY: pos.y,
                                      char: "D",
                                      isVisible: true,
                                      colorPair: color))
                }
            }
        }

        return tiles
    }

    private static func buildItemTiles(items: [Position: ItemProtocol], visiblePositions: Set<Position>) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        for (pos, item) in items {
            if visiblePositions.contains(pos) {
                let (char, color) = symbolAndColorForItem(item)
                tiles.append(Tile(posX: pos.x, posY: pos.y, char: char, isVisible: true, colorPair: color))
            }
        }

        return tiles
    }

    private static func buildExitTile(position: Position) -> DrawableObject {
        return Tile(posX: position.x,
                    posY: position.y,
                    char: "E",
                    isVisible: true,
                    colorPair: ColorCode.white)
    }

    private static func buildEnemyTiles(enemies: [Enemy], visiblePositions: Set<Position>) -> [DrawableObject] {
        var tiles = [DrawableObject]()

        for enemy in enemies {
            let pos = enemy.characteristics.position
            if visiblePositions.contains(pos) {
                let (char, color) = symbolAndColorForEnemy(enemy)
                tiles.append(Tile(posX: pos.x,
                                  posY: pos.y,
                                  char: char,
                                  isVisible: true,
                                  colorPair: color))
            }
        }

        return tiles
    }

    private static func buildPlayerTile(player: Player) -> DrawableObject {
        return Tile(posX: player.characteristics.position.x,
                    posY: player.characteristics.position.y,
                    char: "@",
                    isVisible: true,
                    colorPair: ColorCode.white)
    }

    private static func colorForDoor(_ color: Color) -> Int {
        switch color {
        case .red: return ColorCode.red
        case .green: return ColorCode.green
        case .blue: return ColorCode.blue
        case .none: return ColorCode.white
        }
    }

    private static func symbolAndColorForItem(_ item: ItemProtocol) -> (Character, Int) {
        switch item.type {
        case .food: return ("f", ColorCode.white)
        case .weapon: return ("w", ColorCode.white)
        case .scroll: return ("s", ColorCode.white)
        case .elixir: return ("e", ColorCode.white)
        case .treasure: return ("*", ColorCode.yellow)
        case .key(let colorKey): return ("k", colorForDoor(colorKey))
        }
    }

    private static func symbolAndColorForEnemy(_ enemy: Enemy) -> (Character, Int) {
        switch enemy.type {
        case .zombie: return ("Z", ColorCode.green)
        case .vampire: return ("V", ColorCode.red)
        case .ghost: return ("G", ColorCode.white)
        case .ogre: return ("O", ColorCode.yellow)
        case .snakeMage: return ("S", ColorCode.white)
        case .mimic: return ("M", ColorCode.white)
        }
    }
}

enum ColorCode {
    static let white = 1
    static let red = 2
    static let yellow = 3
    static let blue = 4
    static let green = 5
    static let gray = 6 
}
