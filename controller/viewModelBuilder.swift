//
//  viewModelBuilder.swift
//  rogue

import domain
import presentation

public final class ViewModelBuilder {

    public static func buildGameScreen(from level: Level) -> GameScreenView {
        let visible = VisibilityEngine.computeVisiblePositions(from: level.player.characteristics.position, in: level)
        level.exploredPositions.formUnion(visible)
        let tiles = TileAssembler.buildTiles(
            from: level,
            visiblePositions: visible,
            exploredPositions: level.exploredPositions
        )

        let stats = level.player.characteristics
        let info = String(format: "Level: %d | Keys:     | HP: %d/%d | STR: %d | AGI: %d | Weapon: %@ (+%d)",
                          level.levelNumber,
                          stats.health,
                          stats.maxHealth,
                          stats.strength,
                          stats.agility,
                          level.player.weapon?.weaponType.name ?? "None",
                          level.player.weaponDamage ?? 0)

        return GameScreenView(tiles: tiles,
                              log: GameLogger.shared.currentLog,
                              buffLog: GameLogger.shared.currentBuffLog,
                              info: info)
    }

    public static func buildInventoryViewModel(category: ItemCategory, items: [ItemProtocol], player: Player) -> InventoryView {
        let categoryTitle: String
        switch category {
        case .weapon: categoryTitle = "WEAPON"
        case .food: categoryTitle = "FOOD"
        case .elixir: categoryTitle = "ELIXIR"
        case .scroll: categoryTitle = "SCROLL"
        default: categoryTitle = ""
        }

        let header = "BACKPACK - \(categoryTitle):"
        var itemLines: [String] = []

        if category == .weapon, player.weapon != nil {
            let currentWeapon = player.weapon!.type.name
            itemLines.append("0. Remove weapon (currently: \(currentWeapon) +\(player.weapon!.damage) damage)")
        }

        if items.isEmpty {
            if category != .weapon || player.weapon == nil {
                itemLines.append("There are no items in this category")
            }
        } else {
            for (i, item) in items.prefix(9).enumerated() {
                itemLines.append("\(i + 1). \(describe(item))")
            }
        }

        let hint: String = {
            if category == .weapon {
                switch (player.weapon != nil, items.count > 0) {
                case (false, false): return "Press Esc to return"
                case (true, false): return "Press 0 to remove weapon, Esc to return"
                case (false, true): return "Press 1-\(items.count) to use, Esc to return"
                case (true, true): return "Press 1-\(items.count) to use, 0 to remove weapon, Esc to return"
                }
            } else {
                return items.isEmpty
                    ? "Press Esc to return"
                    : "Press 1-\(items.count) to use, Esc to return"
            }
        }()

        return InventoryView(header: header, items: itemLines, hint: hint)
    }

    private static func describe(_ item: ItemProtocol) -> String {
        var description = item.type.name

        switch item.type {
        case .food(let foodType):
            description += " (+\(foodType.healthRestore) HP)"
        case .weapon(_):
            if let weapon = item as? Weapon {
                description += " (+\(weapon.damage) damage)"
            }
        case .scroll(let scrollType):
            if let scroll = item as? Scroll {
                let effectName = scrollType.name.split(separator: " ").first ?? ""
                description += " (+\(scroll.value) \(effectName))"
            }
        case .elixir(let elixirType):
            if let elixir = item as? Elixir {
                let effectName = elixirType.name.split(separator: " ").first ?? ""
                description += " (+\(elixir.value) \(effectName) for \(Int(elixir.duration))s)"
            }
        default: break
        }

        return description
    }
}

