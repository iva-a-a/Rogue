//
//  map.swift
//  rogue

public class Map {
    var rooms: [Room] = []

    public init() {
        self.generateMap()
    }
    
    func generateRoomInSector(gridX: Int, gridY: Int, sector: Int) -> Room {
        // сектор
        let sectorTop = gridX * Constants.sectorHeight
        let sectorBottom = (gridX + 1) * Constants.sectorHeight - 1
        let sectorLeft = gridY * Constants.sectorWidth
        let sectorRight = (gridY + 1) * Constants.sectorWidth - 1
        
        // генерация случайных размеров комнаты
        let width = Int.random(in: Constants.minWidthRoom...Constants.maxWidthRoom) // ширина (столбцы, y)
        let height = Int.random(in: Constants.minHeightRoom...Constants.maxHeightRoom) // высота (строки, x)
        
        // вычисляем координаты для комнаты
        let y1 = Int.random(in: sectorLeft...(sectorRight - width + 1)) // столбец (y)
        let x1 = Int.random(in: sectorTop...(sectorBottom - height + 1)) // строка (x)
        let y2 = y1 + width - 1
        let x2 = x1 + height - 1
        
        let room = Room((x2, y2), (x1, y1), sector)
        return room
    }
    
    func generateMap() {
        var sector: Int = 1
        for i in 0..<Constants.gridSize {
            for j in 0..<Constants.gridSize {
                print(sector)
                rooms.append(generateRoomInSector(gridX: i, gridY: j, sector: sector))
                sector += 1
            }
        }
    }
}
