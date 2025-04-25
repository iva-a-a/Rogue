//
//  map.swift
//  rogue

public class Map {
    var rooms: [Room] = []
    
    public init() {
        self.generateMap()
    }
    
    func generateRoomInSector(gridX: Int, gridY: Int) -> Room {
        
        // сектор
        let sectorLeft = gridX * Constants.sectorWidth
        let sectorRight = (gridX + 1) * Constants.sectorWidth - 1
        let sectorBottom = gridY * Constants.sectorHeight
        let sectorTop = (gridY + 1) * Constants.sectorHeight - 1
        
        // генерация случайных размеров комнаты
        let width = Int.random(in: Constants.minWidthRoom...Constants.maxWidthRoom)
        let height = Int.random(in: Constants.minHeightRoom...Constants.maxHeightRoom)
        
        // вычисляем координаты для комнаты
        let x1 = Int.random(in: sectorLeft...(sectorRight - width + 1))
        let y1 = Int.random(in: sectorBottom...(sectorTop - height + 1))
        let x2 = x1 + width - 1
        let y2 = y1 + height - 1
        let room = Room((x2, y2),(x1, y1))
        return room
    }
    
    func generateMap() {
        for i in 0..<Constants.gridSize {
            for j in 0..<Constants.gridSize {
                rooms.append(generateRoomInSector(gridX: i, gridY: j))
            }
        }
    }
    
}
