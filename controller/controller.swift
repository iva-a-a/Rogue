//
//  controller.swift
//  rogue

import domain
import presentation

public class Controller {
    // переделать на приватные
    public var level: Level?
    public var state: GameState = .beginning
    
    public init() { }
    
    // если из сохранок
    //    public init(level: Level) {
    //        self.level = level
    //        state = .playing
    //    }
    
    // выполняем действие в записимости от состояния
    private func update(_ input: PlayerAction) {
        switch state {
        case .beginning:
            startGame()
        case .generating:
            generateLevel()
        case .playing:
            gameLoop(input)
        case .inventory:
            break
        case .levelComplete:
            generateLevel()
        case .won: break
            // отрисовка окна проигрыша и статистики
        case .lose: break
            // отрисовка окна выигрыша и статистики
        case .quit: break
            // выход из игры
        }
    }
    
    public func handleInput(_ input: PlayerAction) {
        switch input {
            case .move(_, _):
                if state == .generating || state == .inventory || state == .beginning {
                    state = .playing
                }
            case .exit:
            if state == .playing || state == .won || state == .lose {
                state = .quit
            }
            case .openElixir, .openFood, .openWeapon, .openScroll:
                if state == .playing {
                    state = .inventory
                }
            case .showStats: break
            case .none: break
        }
    }
    
    // принимать нажатую кнопку для старта игры или выбора из сохранок
    private func startGame() {
        state = .generating
        // если из сохранки делаем стейт на плей
    }
    
    // переделать на приватный
    public func generateLevel() {
        // нужно получать сложность для игрока!!!
        self.level = LevelBuilder.buildLevel()
        level?.draw()
        state = .playing
        level?.playerTurn(0, 1)
        level?.draw()
    }

    private func gameLoop(_ input: PlayerAction) {
        guard level != nil else { return }
        guard case .move(let dx, let dy) = input else { return }
        level!.playerTurn(dx, dy)
        if level!.isWin() {
            state = .won
            return
        }
        if level!.isLevelFinished() {
            state = .levelComplete
            return
        }
        level!.enemiesTurn()
        if level!.isLose() {
            state = .lose
            return
        }
    }
    
    // принимать кнопку для открытия нужного инвенторя
//    private func openInventory(_ input: PlayerAction) {
//
//    }
}

