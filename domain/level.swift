//
//  level.swift
//  rogue

public class Level {
    public var rooms: [Room] = []
    public var corridors: [Corridor] = []
    public var player: Player
    public var enemies: [Enemy] = []
    public var items: [Position: ItemProtocol] = [:]

    public let exitPosition: Position
    public var levelNumber: Int
    
    public var gameMap: GameMap

    public init(_ rooms: [Room], _ corridors: [Corridor], _ exitPosition: Position, _ player: Player, _ enemies: [Enemy],_ items: [Position: ItemProtocol], _ levelNumber: Int, _ gameMap: GameMap) {
        self.rooms = rooms
        self.corridors = corridors
        self.exitPosition = exitPosition
        self.player = player
        self.enemies = enemies
        self.items = items
        self.levelNumber = levelNumber
        self.gameMap = gameMap
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

        for enemy in enemies {
            let symbol: String
            switch enemy.type {
            case .zombie:
                symbol = "Z"
            case .vampire:
                symbol = "V"
            case .ghost:
                symbol = "G"
            case .ogre:
                symbol = "O"
            case .snakeMage:
                symbol = "S"
            }
            grid[enemy.characteristics.position.x][enemy.characteristics.position.y] = symbol
        }

        grid[player.characteristics.position.x][player.characteristics.position.y] = "P"


        for row in grid {
            print(row.joined())
       }
        gameMap.printMap()
    }
}
