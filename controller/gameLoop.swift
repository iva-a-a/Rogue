//
//  gameLoop.swift
//  rogue

import domain
import presentation
import Darwin.ncurses

public final class GameLoop {
    private let controller = Controller()
    
    public init() {}
    
    public func start() {
        configureCurses()
        
        var isRunning = true
        while isRunning {
            clear()
            controller.renderLevel()
            refresh()
            
            let action = InputHandler.getAction()
            controller.update(for: action)
            
            if case .quit = controller.state {
                isRunning = false
            }
        }
        endwin()
    }
}
