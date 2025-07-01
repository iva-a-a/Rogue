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
    
    private var actionLog: String?
    private var moveLog: String?
    public private(set) var combatLog: [String] = []
    public private(set) var activeBuffs: [String: Int] = [:]
    
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
            
        case .playerMoved(let position):
            moveLog = "Moved to position: (\(position.x), \(position.y))."
        case .playerNotMoved:
            moveLog = "This movement is not possible."

        case .itemPickedUp(let item):
            actionLog = "You picked up: \(item)."
        case .notPickedUp:
            actionLog = "You can't pick that up, the backpack is full."
        case .weaponDropped(let weapon):
            actionLog = "You dropped: \(weapon)."
        case .eatFood(let food, let amount):
            actionLog = "You ate \(food), restored \(amount) health."
        case .drinkElixir(let elixir, let duration):
            actionLog = "You drank \(elixir), effect lasts \(duration) seconds."
        case .readScroll(let scroll, let amount):
            actionLog = "You read \(scroll), stat increased by \(amount)."
        case .useWeapon(let weapon, let damage):
            actionLog = "You used \(weapon), dealing \(damage) damage."
        case .pickUpTreasure(let treasure, let amount):
            actionLog = "You found \(treasure) worth \(amount)!"
        case .openColorDoor(let color):
            actionLog = "You opened the door with a \(color) Key."
        case .notOpenColorDoor:
            actionLog = "You can't open that door. Find the key of the door color."
        case .levelComplete(let number):
            actionLog = "You completed level \(number). Press any key to continue."
        case .gameOver:
            actionLog = "YOU DIED! Game over!"
        case .gameWon:
            actionLog = "YOU WON! Congratulations!"
        case .buffUpdate(let buffName, let remainingTime):
            if remainingTime > 0 {
                activeBuffs[buffName] = remainingTime
            } else {
                activeBuffs.removeValue(forKey: buffName)
            }
        }
    }

    public func clearCombatLog() {
        combatLog.removeAll()
    }
    
    public var currentLog: String {
        return actionLog ?? moveLog ?? ""
    }
    
    public var currentBuffLog: String {
        return activeBuffs.map { "\($0.key): \($0.value)s" }.joined(separator: " | ")
    }
    
    public func clearActionLog() {
        actionLog = nil
    }
}
