import Foundation
import domain

let (level, map) = LevelBuilder.buildLevel()
level.draw()

map.printMap()
