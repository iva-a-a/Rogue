//
//  controller.swift
//  rogue

import Foundation
import domain
import presentation

public class Controller {
    public var level: Level?
    public var state: GameState = .beginning
    private var inventoryCategory: ItemCategory? = nil
    private var levelNumber: Int = 0
    private let gameRender = GameRenderer()

    private var lastUpdateTime = Date()

    public init() {
        GameEventManager.shared.addObserver(GameLogger.shared)
    }

    public func update(for input: PlayerAction) {
        updateBuffs()
        let previousState = state
        updateState(for: input)
        handleStateSideEffects(from: previousState, to: state, with: input)
        act(for: input)
    }

    private func updateState(for input: PlayerAction) {
        switch state {
        case .beginning:
            if input == .start { state = .generating }
        case .generating: state = .playing
        case .playing:
            switch input {
            case .exit: state = .quit
            case .openWeapon, .openFood, .openElixir, .openScroll: state = .inventory
            default: break
            }
        case .inventory:
            if input == .exit { state = .playing }
        case .levelComplete: state = .generating
        case .won, .lose:
            switch input {
            case .start: state = .generating
            case .exit: state = .quit
            default: break
            }
        case .quit: break
        }
    }

    private func handleStateSideEffects(from oldState: GameState, to newState: GameState, with input: PlayerAction) {
        switch (oldState, newState) {
        case (.beginning, .generating), (.won, .generating), (.lose, .generating):
            levelNumber = 0
            GameLogger.shared.reset()
        case (.playing, .inventory):
            switch input {
            case .openWeapon: inventoryCategory = .weapon
            case .openFood: inventoryCategory = .food
            case .openElixir: inventoryCategory = .elixir
            case .openScroll: inventoryCategory = .scroll
            default: break
            }
        case (.inventory, .playing): inventoryCategory = nil
        default: break
        }
    }
    
    private func act(for input: PlayerAction) {
        switch state {
        case .generating:
            levelNumber += 1
            generateLevel()
        case .playing:
            motion(input)
        case .beginning, .levelComplete, .quit:
            break
        case .inventory:
            itemAction(input)
        case .won, .lose:
            level?.player.deleteActiveBuffs()
        }
    }
    
    private func generateLevel() {
        let player = levelNumber == 1 ? Player() : (level?.player ?? Player())
        player.deleteAllKeys()
        self.level = LevelBuilder.buildLevel(player: player, levelNumber: levelNumber)
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

    public func rendering() {
        guard let level = level else { return }

        if state == .inventory, let category = inventoryCategory {
            gameRender.renderInventory(category: inventoryCategory!,
                                       items: level.getItemsList(category),
                                       player: level.player)
            return
        }
        gameRender.renderLevel(level)
        GameLogger.shared.clearCombatActionLog()
    }
}
