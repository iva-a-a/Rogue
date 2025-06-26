//
//  backpack.swift
//  rogue

public enum ItemCategory: Hashable {
    case food
    case weapon
    case scroll
    case elixir
    case treasure
    case key
}

public class Backpack {
    var items: [ItemCategory: [any ItemProtocol]] = [:]
    public var totalTreasureValue: Int = 0

    public init() {}

    public func useItem(_ player: Player, category: ItemCategory, index: Int) {
        guard var itemArray = items[category], itemArray.indices.contains(index) else { return }

        let item = itemArray[index]
        itemArray.remove(at: index)
        items[category] = itemArray.isEmpty ? [] : itemArray
        item.use(player)
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
}
