//
//  backpack.swift
//  rogue


public enum ItemCategory: Hashable {
    case food
    case weapon
    case scroll
    case elixir
    case treasure
}

public class Backpack {
    var items: [ItemCategory: [any ItemProtocol]] = [:]
    public var totalTreasureValue: Int = 0

    public init() {}

    public func useItem(_ player: Player, category: ItemCategory, index: Int) {
        guard var itemArray = items[category], itemArray.indices.contains(index) else { return }
        itemArray[index].use(player)
        itemArray.remove(at: index)
        items[category] = itemArray.isEmpty ? [] : itemArray
    }
    
    public func addItem(_ item: any ItemProtocol) -> AddingCode {
        let category = item.type.category
        var categoryItems = items[category] ?? []

        if categoryItems.count < Constants.Item.maxCount {
            categoryItems.append(item)
            items[category] = categoryItems
            return .success
        }
        return .isFull
    }
    public func getAllItems() -> [any ItemProtocol] {
        return items.flatMap { $0.value } 
    }
}
