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
    private var lastUpdateTime = Date()
    private var currentDifficulty: GameDifficulty = .normal
    
    private let statsTracker = GameStatsTracker()
    private let dataLayer = DataLayer()
    
    private let menu = MenuRender(type: .main)
    private lazy var exitMenu = MenuRender(type: .pause)
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
                default: break
                }
            }
        case .generating: state = .playing
        case .playing:
            switch input {
            case .exit: state = .pause
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
        case .pause:
            if let action = exitMenu.handleInput(input) {
                switch action {
                case .resume: state = .playing
                case .menu: state = .beginning
                case .exit: state = .quit
                default: break
                }
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
        case (.beginning, .showLeaderboard):  leaderboard.resetOffset()
        case (.pause, .beginning), (.pause, .quit):
            GameEventManager.shared.notify(.saveGame)
            menu.resetSelect()
        case (.playing, .pause): exitMenu.resetSelect()
        case (.showLeaderboard, .beginning): menu.resetSelect()
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
        case .inventory:
            itemAction(input)
        case .won, .lose:
            level?.player.deleteActiveBuffs()
        case .loading:
            GameEventManager.shared.notify(.loadGame)
        case .showLeaderboard:
            leaderboard.handleInput(input)
        case .quit:
            GameLogger.shared.saveLogsToFile()
        default: break
        }
    }
    
    private func generateLevel() {
        let player = levelNumber == ControllerConstants.initialLevelNumber ? Player() : (level?.player ?? Player())
        let stats = GameStatsLevel.shared.currentStats()
        let difficulty = DifficultyCalculator.getDifficulty(
            for: player,
            for: levelNumber,
            for: currentDifficulty
        )
        self.currentDifficulty = difficulty

        let difficultyMessage = levelNumber > ControllerConstants.initialLevelNumber ?
            "Level \(levelNumber) (\(difficulty.stringValue)) | Previous: \(stats.defeatedEnemies) kills, \(stats.receivedDamage) dmg, \(stats.itemsUsed) items" :
            "Level \(levelNumber) (\(difficulty.stringValue)) | New game started"
        
        GameLogger.shared.didReceiveEvent(event: .operationSuccess(message: difficultyMessage))
        self.level = LevelBuilder.buildLevel(player: player, difficulty: difficulty, levelNumber: levelNumber)
        GameStatsLevel.shared.didReceiveEvent(event: .levelGenerated)
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
        if currentTime.timeIntervalSince(lastUpdateTime) >= ControllerConstants.buffUpdateInterval {
            level?.player.updateBuffs()
            lastUpdateTime = currentTime
        }
    }
    
    public func rendering() {
        if let tempLog = menu.getTemporaryMessage(), tempLog.expiration < Date() {
            menu.resetTemporaryMessage()
        }
        switch state {
        case .beginning:
            menu.render()
            menu.renderTemporaryMessage()
        case .showLeaderboard: leaderboard.render(attempts: MapperLeaderboard.toViewModel(dataLayer.getSortedGameAttempts()))
        case .pause: exitMenu.render()
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
            GameLogger.shared.didReceiveEvent(event: .operationSuccess(message: "The game was saved successfully!"))
        } catch let error {
            GameLogger.shared.didReceiveEvent(event: .operationFailed(error: error.localizedDescription))
        }
    }
    
    private func loadGame() {
        do {
            if let dto = try dataLayer.loadLevelDTO() {
                self.level = LevelMapper.toDomain(dto)
                self.levelNumber = dto.levelNumber
                self.state = .playing
                GameLogger.shared.didReceiveEvent(event: .operationSuccess(message: "The game has been uploaded successfully!"))
            } else {
                state = .beginning
                menu.setTemporaryMessage()
                GameLogger.shared.didReceiveEvent(event: .operationFailed(error: "No saved games found"))
            }
        } catch let error {
            state = .beginning
            GameLogger.shared.didReceiveEvent(event: .operationFailed(error: error.localizedDescription))
        }
    }
}

extension Controller: GameEventObserver {
    public func didReceiveEvent(event: GameEvent) {
        switch event {
        case .saveGame: saveGame()
        case .loadGame: loadGame()
        default: break
        }
    }
}

enum ControllerConstants {
    static let initialLevelNumber = 1
    static let buffUpdateInterval: TimeInterval = 1.0
}
