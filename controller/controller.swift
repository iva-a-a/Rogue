//
//  controller.swift
//  rogue

import domain
import presentation
import Darwin.ncurses

public class Controller {
    private var level: Level?
    public var state: GameState = .beginning
    private let renderer = LevelRenderer()
    private var inventoryCategory: ItemCategory? = nil
    
    public init() { }
    
    public func update(for input: PlayerAction) {
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
            // можно показать сообщение и ждать нажатие кнопки !!
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
    
    public func renderLevel() {
    guard let level = level else { return }

    if state == .inventory, let category = inventoryCategory {
        let items = level.getItemsList(category)
        clear()
        
        renderer.drawString("Inventory: \(category)", atY: 0, x: 0)
        
        if items.isEmpty {
            renderer.drawString("There are no items in this category", atY: 2, x: 0)
            renderer.drawString("Press Esc to return", atY: 4, x: 0)
            return
        }

        for (i, item) in items.prefix(9).enumerated() {
            let line = "\(i + 1). \(item.type.name)"
            renderer.drawString(line, atY: i + 1, x: 0)
        }

        if category == .weapon {
            renderer.drawString("0. Remove the weapon from your hands", atY: 10, x: 0)
        }

        renderer.drawString("Press 1-9 to use, Esc — back", atY: 12, x: 0)
        return
    }

    let visible = VisibilityEngine.computeVisiblePositions(from: level.player.characteristics.position, in: level)
    level.exploredPositions.formUnion(visible)

    let tiles = TileAssembler.buildTiles(
        from: level,
        visiblePositions: visible,
        exploredPositions: level.exploredPositions
    )

    renderer.drawTiles(tiles)

    let log = GameLogger.shared.log
    let logY = Int(LINES) - 1
    renderer.drawString(String(repeating: " ", count: 80), atY: logY, x: 0)
    renderer.drawString(log, atY: logY, x: 0)
}
    
    private func renderInventory(for category: ItemCategory, items: [ItemProtocol]) {
        clear()
        renderer.drawString("Inventory: \(category)", atY: 0, x: 0)
        
        for (i, item) in items.prefix(9).enumerated() {
            let line = "\(i + 1). \(item.type.name)"
            renderer.drawString(line, atY: i + 1, x: 0)
        }
        
        renderer.drawString("Press 1-9 to use, Esc to return", atY: 11, x: 0)
    }
}
