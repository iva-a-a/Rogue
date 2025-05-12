enum AddingCode {
    case success
    case isFull
}

@propertyWrapper 
struct ItemsAccess<T: Item> {
    private var items: [T]
    var wrappedValue: [T] {
        get { return items }
        set { items = newValue }
    }

    init() {
        items = [T]()
    }

    mutating func addNewItem(item: T) -> AddingCode {
        if items.count < 9 {
            items.append(item) 
            return .success
        }
        return .isFull
    }

    mutating func deleteItem(index: Int) {
        items.remove(at: index)
    }
}

class Backpack {
    var size: Int = 0
    @ItemsAccess var foods: [Food]
    @ItemsAccess var scrolls: [Scroll]
    @ItemsAccess var elixirs: [Elixir]
    @ItemsAccess var weapons: [Weapon]
    var treasures: Treasure = Treasure(value: 0)

    func addItem(item: Item) -> AddingCode {
        if item is Food {
            return _foods.addNewItem(item: item as! Food)
        }
        else if item is Scroll {
            return _scrolls.addNewItem(item: item as! Scroll)
        }
        else if item is Elixir {
            return _elixirs.addNewItem(item: item as! Elixir)
        }
        else if item is Weapon {
            return _weapons.addNewItem(item: item as! Weapon)
        }
        else if item is Treasure {
            treasures.value += (item as! Treasure).value
        }
        return .success
    }
}