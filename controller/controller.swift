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
    
    public init() { }
    
    public func update(_ input: PlayerAction) {
        handleInput(input)
        switch state {
        case .beginning:
            startGame()
        case .generating:
            generateLevel()
        case .playing:
            tick(input)
        case .inventory:
            // Обработка инвентаря
            break
        case .levelComplete:
//            generateLevel()
            break
        case .won, .lose:
            // Отрисовка экрана победы/поражения
            break
        case .quit:
            // Выход из игры
            break
        }
    }
    
    public func handleInput(_ input: PlayerAction) {
        switch input {
        case .move(let dx, let dy):
            if state == .generating || state == .beginning {
                state = .playing
            } else if state == .playing {
                // Обработка движения уже в gameLoop
            }
        case .exit:
            state = .quit
        case .openElixir, .openFood, .openWeapon, .openScroll:
            if state == .playing {
                state = .inventory
            }
        case .showStats:
            // Показать статистику
            break
        case .none:
            break
        case .start:
            state = .generating
        }
    }
    
    private func startGame() {
        state = .generating
    }
    
    private func generateLevel() {
        self.level = LevelBuilder.buildLevel()
        state = .playing
    }

    private func tick(_ input: PlayerAction) {
        guard let level = level else { return }
        
        if case .move(let dx, let dy) = input {
            level.playerTurn(dx, dy)
            
            if level.isWin() {
                state = .won
                return
            }
            
            if level.isLevelFinished() {
                state = .levelComplete
                return
            }
            
            level.enemiesTurn()
            
            if level.isLose() {
                state = .lose
                return
            }
        }
    }
    
    public func renderLevel() {
        guard let level = level else { return }
        let tiles = TileAssembler.buildTiles(from: level)
        renderer.drawTiles(tiles)
        let log = GameLogger.shared.log
        // Получаем высоту экрана (LINES — глобальная переменная из ncurses)
        let logY = Int(LINES) - 1
        renderer.drawString(String(repeating: " ", count: 80), atY: logY, x: 0)
        // Печатаем лог
        renderer.drawString(log, atY: logY, x: 0)
    }
}
