//
//  controller.swift
//  rogue
import Foundation
import domain
import presentation

public class Controller {
    public var level: Level?
    public var state: GameState = .beginning
    private let renderer = Render()
    private var inventoryCategory: ItemCategory? = nil

    private var lastUpdateTime = Date()

    public init() {
        GameEventManager.shared.addObserver(GameLogger.shared)
    }

    public func update(for input: PlayerAction) {
        GameLogger.shared.clearCombatLog()
        GameLogger.shared.clearActionLog()
        updateBuffs()
        updateState(for: input)
        act(for: input)
    }

    private func updateState(for input: PlayerAction) {
        switch state {
        case .beginning:
            if input == .start { state = .generating }
        case .generating:
            state = .playing
            break
        case .playing:
            if input == .exit { state = .quit }

            if input == .openWeapon { state = .inventory; inventoryCategory = .weapon }
            if input == .openFood { state = .inventory; inventoryCategory = .food }
            if input == .openElixir { state = .inventory; inventoryCategory = .elixir }
            if input == .openScroll { state = .inventory; inventoryCategory = .scroll }
        case .inventory:
            if input == .exit { state = .playing; inventoryCategory = nil }
        case .levelComplete:
            state = .generating
        case .won, .lose:
            if input == .start { state = .beginning }
            if input == .exit { state = .quit }
        case .quit:
            break
        }
    }

    private func act(for input: PlayerAction) {
        switch state {
        case .generating:
            generateLevel()
        case .playing:
            motion(input)
        case .levelComplete:
            break
        case .won:
            // показать окно выигрыша
            break
        case .lose:
            // показать окно проигрыша
            break
        case .inventory:
            itemAction(input)
        case .quit:
            // Выход из игры
            break
        case .beginning:
            break
        }
    }

    private func generateLevel() {
        let player = level?.player ?? Player()
        player.deleteAllKeys()
        self.level = LevelBuilder.buildLevel(player: player)
    }

    private func motion(_ input: PlayerAction) {
        guard let level = level else  { return }

        if case .move(let dx, let dy) = input {
            level.playerTurn(dx, dy)
            if level.isWin() {
                state = .won
                GameEventManager.shared.notify(.gameWon)
                return
            }
            if level.isLevelFinished() {
                GameEventManager.shared.notify(.levelComplete(number: level.levelNumber))
                state = .levelComplete
                return
            }
            level.enemiesTurn()
            if level.isLose() {
                state = .lose
                GameEventManager.shared.notify(.gameOver)
                return
            }
        }
    }

    private func itemAction(_ input: PlayerAction) {
        guard let level = level else  { return }
        if case .useItem(let index) = input {
            level.player.useItem(category: inventoryCategory!, index: index)
            state = .playing
            inventoryCategory = nil
        } else if input == .dropWeapon {
            level.dropWeapon()
            state = .playing
            inventoryCategory = nil
        }
    }

    private func updateBuffs() {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastUpdateTime) >= 1.0 {
            level?.player.updateBuffs()
            lastUpdateTime = currentTime
        }
    }

    public func renderLevel() {
        guard let level = level else { return }

        if state == .inventory, let category = inventoryCategory {
            renderInventory(for: category, items: level.getItemsList(category))
            return
        }

        let tiles = TileAssembler.buildTiles(from: level)
        renderer.drawTiles(tiles)
        renderInfo()
        renderLog()
    }

    // переделать
    private func renderInventory(for category: ItemCategory, items: [ItemProtocol]) {
        clear()
        renderer.drawString("Inventory: \(category)", atY: 0, atX: 0)

        for (i, item) in items.prefix(9).enumerated() {
            let line = "\(i + 1). \(item.type.name)"
            renderer.drawString(line, atY: i + 1, atX: 0)
        }

        renderer.drawString("Press 1-9 to use, Esc to return", atY: 11, atX: 0)
    }

    private func renderLog() {
        let logger = GameLogger.shared

        for i in 0..<RenderPadding.logCombatStr {
            renderer.drawString(String(repeating: " ", count: RenderPadding.length),
                              atY: RenderPadding.logTop + i, atX: RenderPadding.null)
        }

        if logger.combatLog.isEmpty {
            renderer.drawString(logger.currentLog,
                              atY: RenderPadding.logTop, atX: RenderPadding.null)
        } else {
            for (i, line) in logger.combatLog.enumerated() {
                renderer.drawString(line,
                                   atY: RenderPadding.logTop + i,
                                   atX: RenderPadding.null)
            }
        }

        renderer.drawString(String(repeating: " ", count: RenderPadding.length),
                           atY: RenderPadding.logBuffTop, atX: RenderPadding.null)

        if !logger.currentBuffLog.isEmpty {
            renderer.drawString(logger.currentBuffLog,
                               atY: RenderPadding.logBuffTop, atX: RenderPadding.null)
        }
    }

    private func renderInfo() {
        guard let level = level else { return }

        let player = level.player
        let stats = player.characteristics

        let infoString = String(format: "Level: %d | HP: %d/%d | STR: %d | AGI: %d | Weapon: %@",
                                level.levelNumber,
                                stats.maxHealth,
                                stats.health,
                                stats.strength,
                                stats.agility,
                                player.weapon?.weaponType.name ?? "None")

        renderer.drawString(String(repeating: " ", count: RenderPadding.length),
                            atY: RenderPadding.infoTop,
                            atX: RenderPadding.null)
        renderer.drawString(infoString, atY: RenderPadding.infoTop, atX: RenderPadding.null)
    }
}

enum RenderPadding {
    static let logTop = 27
    static let logBuffTop = 26
    static let null = 0
    static let infoTop = 25
    static let length = 80
    static let logCombatStr = 5
}
