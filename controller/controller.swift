//
//  controller.swift
//  rogue

import Foundation
import domain
import presentation
import data
import services

public class Controller {
    private var level: Level?
    public var state: GameState = .beginning
    private var inventoryCategory: ItemCategory? = nil
    private var levelNumber: Int = 0

    private let statsTracker = GameStatsTracker()
    private var lastUpdateTime = Date()
    private let dataLayer = DataLayer()
    
    private let menu = MenuRender()
    private let gameRender = GameRenderer()
    private let leaderboard = LeaderboardRenderer()
    
    public init() {
        GameEventManager.shared.addObserver(GameLogger.shared)
        GameEventManager.shared.addObserver(self)
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
            if let action = menu.handleInput(input) {
                switch action {
                case .start: state = .generating
                case .load: state = .loading
                case .leadboard: state = .showLeaderboard
                case .exit: state = .quit
                }
            }
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
        case .loading: state = .playing
        case .showLeaderboard:
            if input == .exit { state = .beginning }
        case .quit: state = .beginning
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
        case (.beginning, .showLeaderboard):  leaderboard.resetOffset()
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
        case .beginning, .levelComplete:
            break
        case .inventory:
            itemAction(input)
        case .won, .lose:
            level?.player.deleteActiveBuffs()
        case .loading:
            GameEventManager.shared.notify(.loadGame)
        case .showLeaderboard:
            leaderboard.handleInput(input)
        case .quit: saveGame()
        }
    }
    
    private func generateLevel() {
        let player = levelNumber == 1 ? Player() : (level?.player ?? Player())
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
        switch state {
        case .beginning: menu.render()
        case .showLeaderboard: leaderboard.render(attempts: MapperLeaderboard.toViewModel(dataLayer.getSortedGameAttempts()))
        case .inventory:
            guard let level = level, let category = inventoryCategory else { return }
            let inventoryView = ViewModelBuilder.buildInventoryViewModel(category: category,
                                                                         items: level.getItemsList(category),
                                                                         player: level.player)
            gameRender.renderInventory(inventoryView)
        default:
            guard let level = level else { return }
            let gameView = ViewModelBuilder.buildGameScreen(from: level)
            gameRender.renderGameScreen(gameView)
            GameLogger.shared.clearCombatActionLog()
        }
    }
    
    private func saveGame() {
        guard let level = level else { return }
        let dto = LevelMapper.toDTO(level)
        do {
            try dataLayer.saveLevelDTO(dto)
        } catch {

        }
    }

    private func loadGame() {
        do {
            if let dto = try dataLayer.loadLevelDTO() {
                self.level = LevelMapper.toDomain(dto)
                self.levelNumber = dto.levelNumber
                self.state = .playing
            }
        } catch {
           // GameLogger.shared.didReceiveEvent(event: .notSaveStats)
        }
    }
}

extension Controller: GameEventObserver {
    public func didReceiveEvent(event: GameEvent) {
        switch event {
        case .saveGame:
            saveGame()
        case .loadGame:
            loadGame()
        default:
            break
        }
    }
}
