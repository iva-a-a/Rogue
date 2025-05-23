//
//  level.swift
//  rogue

public class Level {
    public var rooms: [Room] = []
    public var corridors: [Corridor] = []
    public var player: Player
//    public var enemies: [Enemy] = []
    public var items: [Position: ItemProtocol] = [:]

    public let exitPosition: Position
    public var levelNumber: Int

    public init(_ rooms: [Room], _ corridors: [Corridor], _ exitPosition: Position, _ player: Player, _ items: [Position: ItemProtocol], _ levelNumber: Int) {
        self.rooms = rooms
        self.corridors = corridors
        self.exitPosition = exitPosition
        self.player = player
        self.items = items
        self.levelNumber = levelNumber
    }

    public func draw() {
        var grid = Array(repeating: Array(repeating: " ", count: Constants.Map.width), count: Constants.Map.height)

        for room in rooms {
            for x in room.lowLeft.x...room.topRight.x {
                for y in room.lowLeft.y...room.topRight.y {
                    if x == room.lowLeft.x || x == room.topRight.x || y == room.lowLeft.y || y == room.topRight.y {
                        grid[x][y] = "#"
                        if room.isStartRoom {
                            grid[x][y] = "@"
                        }
                    }
                }
            }
            for door in room.doors {
                switch door.direction {
                case .up: grid[door.position.x][door.position.y] = "^"
                case .left: grid[door.position.x][door.position.y] = "<"
                case .down: grid[door.position.x][door.position.y] = "v"
                case .right: grid[door.position.x][door.position.y] = ">"
                }
            }
        }

        for corridor in corridors {
            for position in corridor.route {
                if grid[position.x][position.y] == " " {
                    grid[position.x][position.y] = "."
                }
            }
        }

        grid[exitPosition.x][exitPosition.y] = "E"
    

        for (position, item) in items {
            let symbol: String
            switch item.type {
            case .food:
                symbol = "f"
            case .weapon:
                symbol = "w"
            case .scroll:
                symbol = "s"
            case .elixir:
                symbol = "e"
            case .treasure:
                symbol = "t"
            }
            grid[position.x][position.y] = symbol
        }

        grid[player.characteristics.position.x][player.characteristics.position.y] = "P"


        for row in grid {
            print(row.joined())
       }
    }
}
