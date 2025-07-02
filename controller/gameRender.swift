//
//  gameRender.swift
//  rogue

import domain
import presentation
import Darwin.ncurses

final class GameRenderer {
    private let renderer = Render()
    
    func renderLevel(_ level: Level) {
        let tiles = TileAssembler.buildTiles(from: level)
        renderer.drawTiles(tiles)
        renderInfo(for: level)
        renderLog()
    }
    
    func renderInventory(category: ItemCategory, items: [ItemProtocol], player: Player) {
        clear()
        renderInventoryHeader(category: category, player: player)
        renderInventoryItems(category: category, items: items, player: player)
        renderInventoryHint(category: category, itemsCount: items.count, player: player)
    }

    private func renderLog() {
        let logger = GameLogger.shared
        
        for i in 0..<RenderPadding.logCombatStr {
            renderer.drawString(String(repeating: " ", count: RenderPadding.length),
                                atY: RenderPadding.logTop + i,
                                atX: RenderPadding.zero)
        }
        renderer.drawString(String(repeating: " ", count: RenderPadding.length),
                            atY: RenderPadding.logBuffTop,
                            atX: RenderPadding.zero)
        
        renderer.drawString(logger.currentLog,
                            atY: RenderPadding.logTop,
                            atX: RenderPadding.zero)
        
        if !logger.currentBuffLog.isEmpty {
            renderer.drawString(logger.currentBuffLog,
                                atY: RenderPadding.logBuffTop,
                                atX: RenderPadding.zero)
        }
    }

    private func renderInfo(for level: Level) {
        let player = level.player
        let stats = player.characteristics

        let infoString = String(format: "Level: %d | HP: %d/%d | STR: %d | AGI: %d | Weapon: %@ (+%d)",
                                level.levelNumber,
                                stats.maxHealth,
                                stats.health,
                                stats.strength,
                                stats.agility,
                                player.weapon?.weaponType.name ?? "None",
                                player.weaponDamage ?? 0)

        renderer.drawString(String(repeating: " ", count: RenderPadding.length),
                            atY: RenderPadding.infoTop,
                            atX: RenderPadding.zero)
        renderer.drawString(infoString,atY: RenderPadding.infoTop,
                            atX: RenderPadding.zero)
    }

    private func renderInventoryHeader(category: ItemCategory, player: Player) {
        let categoryTitle = getCategoryTitle(category)
        renderer.drawString("BACKPACK - \(categoryTitle):",
                            atY: RenderPadding.zero,
                            atX: RenderPadding.itemLeft)

        if category == .weapon, player.weapon != nil {
            let currentWeapon = player.weapon!.type.name
            let removeWeaponText = "0. Remove weapon (currently: \(currentWeapon))"
            renderer.drawString(removeWeaponText,
                                atY: RenderPadding.zero + RenderPadding.inventoryAfterTitle,
                                atX: RenderPadding.itemLeft + RenderPadding.itemIndent)
        }
    }
    
    private func renderInventoryItems(category: ItemCategory, items: [ItemProtocol], player: Player) {
        let baseY = RenderPadding.zero + RenderPadding.inventoryAfterTitle
        let startY: Int

        if category == .weapon {
            if items.isEmpty {
                if player.weapon == nil {
                    let noItemsText = "There are no items in this category"
                    renderer.drawString(noItemsText, atY: baseY,
                                        atX: RenderPadding.itemLeft + RenderPadding.itemIndent)
                }
                return
            } else {
                startY = baseY + (player.weapon != nil ? 1 : 0)
            }
        } else {
            startY = baseY
        }

        for (i, item) in items.prefix(9).enumerated() {
            let yPos = startY + i
            let itemText = "\(i + 1). \(getItemDescription(item))"
            renderer.drawString(itemText, atY: yPos,
                                atX: RenderPadding.itemLeft + RenderPadding.itemIndent)
        }
    }

    private func renderInventoryHint(category: ItemCategory, itemsCount: Int, player: Player) {
        let baseY = RenderPadding.zero + RenderPadding.inventoryAfterTitle
        var yPos: Int
        let hintText: String

        if category == .weapon {
            switch (player.weapon != nil, itemsCount > 0) {
            case (false, false):
                hintText = "Press Esc to return"
                yPos = baseY + RenderPadding.itemIndent
            case (true, false):
                hintText = "Press 0 to remove weapon, Esc to return"
                yPos = baseY + RenderPadding.itemIndent
            case (false, true):
                hintText = "Press 1-\(itemsCount) to use, Esc to return"
                yPos = baseY + itemsCount + RenderPadding.inventoryHintOffset
            case (true, true):
                hintText = "Press 1-\(itemsCount) to use, 0 to remove weapon, Esc to return"
                yPos = baseY + itemsCount + RenderPadding.itemIndent
            }
        } else {
            if itemsCount == 0 {
                renderer.drawString("There are no items in this category", atY: baseY,
                                    atX: RenderPadding.itemLeft + RenderPadding.itemIndent)
                hintText = "Press Esc to return"
                yPos = baseY + 1 + RenderPadding.inventoryHintOffset
            } else {
                hintText = "Press 1-\(itemsCount) to use, Esc to return"
                yPos = baseY + itemsCount + RenderPadding.inventoryHintOffset
            }
        }
        renderer.drawString(hintText, atY: yPos, atX: RenderPadding.itemLeft)
    }
    
    private func getCategoryTitle(_ category: ItemCategory) -> String {
        switch category {
        case .weapon: return "WEAPON"
        case .food: return "FOOD"
        case .elixir: return "ELIXIR"
        case .scroll: return "SCROLL"
        default: return ""
        }
    }
    
    private func getItemDescription(_ item: ItemProtocol) -> String {
        var description = item.type.name
        
        switch item.type {
        case .food(let foodType):
            description += " (+\(foodType.healthRestore) HP)"
        case .weapon(_):
            if let weapon = item as? Weapon {
                description += " (\(weapon.damage) damage)"
            }
        case .scroll(let scrollType):
            if let scroll = item as? Scroll {
                let effectName = scrollType.name.split(separator: " ").first ?? ""
                description += " (+\(scroll.value) \(effectName))"
            }
        case .elixir(let elixirType):
            if let elixir = item as? Elixir {
                let effectName = elixirType.name.split(separator: " ").first ?? ""
                description += " (+\(elixir.value) \(effectName) forces lasting \(Int(elixir.duration))s)"
            }
        default: break
        }
        
        return description
    }
}

enum RenderPadding {
    static let zero = 0
    static let length = 150

    static let logTop = 27
    static let logBuffTop = 26
    static let logCombatStr = 5

    static let infoTop = 25

    static let itemLeft = 3
    static let itemIndent = 2

    static let inventoryAfterTitle = 2
    static let inventoryHintOffset = 1
}
