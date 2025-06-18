//
//  observer.swift
//  rogue

protocol GameEventObserver: AnyObject {
    func didReceiveEvent(event: GameEvent)
}

class GameEventManager {
    static let shared = GameEventManager()
    
    private var observers: [GameEventObserver] = []

    private init() {}

    func addObserver(_ observer: GameEventObserver) {
        observers.append(observer)
    }

    func removeObserver(_ observer: GameEventObserver) {
        observers.removeAll { $0 === observer }
    }

    func notify(_ event: GameEvent) {
        observers.forEach { $0.didReceiveEvent(event: event) }
    }
}

class GameLogger: GameEventObserver {
    static let shared = GameLogger()
    
    private(set) var log: String = ""
    
    private init() {}
    
    func didReceiveEvent(event: GameEvent) {
        switch event {
        case .playerMissed(let target):
            log = "You missed the enemy \(target)!"
        case .playerSleep:
            log =  "You've been drugged - skipping your turn"
        case .playerSkipMove:
            log = "You skipped your turn"
        case .playerHit(let target, let damage):
            log = "You hit \(target) for \(damage) damage!"
        case .enemyMissed(let enemy):
            log = "\(enemy) missed you!"
        case .enemyHit(let enemy, let damage):
            log = "\(enemy) hit you for \(damage) damage!"
        case .enemyDefeated(let enemy):
            log = "You defeated \(enemy)!"
        case .itemPickedUp(let item):
            log = "You picked up: \(item)"
        case .NotPickedUp:
            log = "You can't pick that up, the backpack is full"
        case .weaponDropped(let weapon):
            log = "You dropped: \(weapon)"
        case .playerMoved(let position):
            log = "Moved to position: (\(position.x), \(position.y))"
        case .eatFood(let food, let amount):
            log = "You ate \(food), restored \(amount) health"
        case .drinkElixir(let elixir, let duration):
            log = "You drank \(elixir), effect lasts \(duration) seconds"
        case .readScroll(let scroll, let amount):
            log = "You read \(scroll), stat increased by \(amount)"
        case .useWeapon(let weapon, let damage):
            log = "You used \(weapon), dealing \(damage) damage"
        case .pickUpTreasure(let treasure, let amount):
            log = "You found \(treasure) worth \(amount) gold"
        case .openColorDoor(let color):
            log = "You opened the door with a \(color)"
        case .NotOpenColorDoor:
            log = "You can't open that door. Find the key of the door color"
        }
    }
}

