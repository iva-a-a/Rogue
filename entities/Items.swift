import Foundation

protocol Item {

}

struct Treasure: Item {
    var value: Int
}

struct Weapon: Item {
    var strength: Int
    var name: String
}

struct Scroll: Item {
    var stat: StatType
    var increase: Int
    var name: String    
}

struct Elixir: Item {
    var duration: TimeInterval
    var stat: StatType
    var increase: Int
    var name: String    
}

struct Food: Item {
    var toRegen: Int
    var name: String
}

class ItemInRoom {
    var item: Item 
    var geometry: Object

    init(item: Item, geometry: Object) {
        self.item = item 
        self.geometry = geometry
    }
}