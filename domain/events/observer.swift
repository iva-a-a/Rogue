//
//  observer.swift
//  rogue

public protocol GameEventObserver: AnyObject {
    func didReceiveEvent(event: GameEvent)
}

public class GameEventManager {
    public static let shared = GameEventManager()
    
    private var observers: [GameEventObserver] = []

    private init() {}

    public func addObserver(_ observer: GameEventObserver) {
        observers.append(observer)
    }

    func removeObserver(_ observer: GameEventObserver) {
        observers.removeAll { $0 === observer }
    }

    public func notify(_ event: GameEvent) {
        observers.forEach { $0.didReceiveEvent(event: event) }
    }
}

public class GameLogger: GameEventObserver {
    public static let shared = GameLogger()
    
    public private(set) var log: String = ""
    public private(set) var combatLog: [String] = []
    
    private init() {}
    
    public func didReceiveEvent(event: GameEvent) {
        switch event {
        case .playerMissed(let target):
            combatLog.append("You missed the enemy \(target)!")
        case .playerHit(let target, let damage, let remainingHealth):
            combatLog.append("You hit \(target) for \(damage) damage! He has \(remainingHealth) health left.")
        case .enemyMissed(let enemy):
            combatLog.append("\(enemy) missed you!")
        case .enemyHit(let enemy, let damage):
            combatLog.append("\(enemy) hit you for \(damage) damage!")
        case .enemyDefeated(let enemy):
            combatLog.append("You defeated \(enemy)!")
        case .playerSleep:
            combatLog.append("You've been drugged - skipping your turn...")
        case .playerSkipMove:
            combatLog.append("You skipped your turn!")

        case .itemPickedUp(let item):
            log = "You picked up: \(item)."
        case .notPickedUp:
            log = "You can't pick that up, the backpack is full."
        case .weaponDropped(let weapon):
            log = "You dropped: \(weapon)."
        case .playerMoved(let position):
            log = "Moved to position: (\(position.x), \(position.y))."
        case .playerNotMoved:
            log = "This movement is not possible."
        case .eatFood(let food, let amount):
            log = "You ate \(food), restored \(amount) health."
        case .drinkElixir(let elixir, let duration):
            log = "You drank \(elixir), effect lasts \(duration) seconds."
        case .readScroll(let scroll, let amount):
            log = "You read \(scroll), stat increased by \(amount)."
        case .useWeapon(let weapon, let damage):
            log = "You used \(weapon), dealing \(damage) damage."
        case .pickUpTreasure(let treasure, let amount):
            log = "You found \(treasure) worth \(amount) gold!"
        case .openColorDoor(let color):
            log = "You opened the door with a \(color)."
        case .notOpenColorDoor:
            log = "You can't open that door. Find the key of the door color."
        case .levelComplete(let number):
            log = "You completed level \(number). Press any key to continue."
        case .gameOver:
            log = "YOU DIED! Game over!"
        case .gameWon:
            log = "YOU WON! Congratulations!"
        }
    }

    public func clearCombatLog() {
        combatLog.removeAll()
    }
}
