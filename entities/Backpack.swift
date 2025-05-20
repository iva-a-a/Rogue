enum AddingCode {
    case success
    case isFull
}

class Backpack {
    var backpack: [ItemType : [any Item]] = [:]
    var treasure: Treasure

    init(value: Int = 0) {
        for item in ItemType.allCases {
            self.backpack[item] = []
        }
        treasure = Treasure(value: value)
    }

    func addItem(item: any Item) -> AddingCode{
        if backpack[item.type]!.count < 9 {
            backpack[item.type]!.append(item)
            return .success
        }
        return .isFull
    }

    // func useItem(_ p: Player, item: Item) {
    //     item.use(p) 
    //     // need to delete from backpack
    //     backpack[item.type]!
    // }

    func useItem(_ p: Player, type: ItemType, index: Int) {
        backpack[type]![index].use(p)
        backpack[type]!.remove(at: index)
    }

    subscript (itemType: ItemType) -> [any Item]? {
        get {
            return backpack[itemType]
        }
    }
}