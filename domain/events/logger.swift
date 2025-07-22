//
//  logger.swift
//  rogue

import Foundation

public class GameLogger: GameEventObserver {
    public static let shared = GameLogger()

    private var actionLog: String?
    private var moveLog: String?
    private var combatLog: [String] = []
    private var activeBuffs: [String: [BuffInfo]] = [:]
    private var endLog: String = ""
    private var operationLog: [String] = []
    private let logFileName = "log.txt"

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
            endLog = "YOU DIED! Game over!\nPress \"Enter\" to restart or \"Esc\" to exit."
        case .gameWon:
            endLog = "YOU WON! Congratulations!\nPress \"Enter\" to restart or \"Esc\" to exit."
        case .buffUpdate(let buffName, let buffInfo):
            if buffInfo.isEmpty {
                activeBuffs.removeValue(forKey: buffName)
            } else {
                activeBuffs[buffName] = buffInfo
            }
        case .operationSuccess(let message):
            operationLog.append(message)
        case .operationFailed(let error):
            operationLog.append("Error: \(error)")
        default: break
        }
    }

    public func clearCombatActionLog() {
        combatLog.removeAll()
        actionLog = nil
    }

    public func reset() {
        actionLog = nil
        moveLog = nil
        combatLog.removeAll()
        activeBuffs.removeAll()
        endLog = ""
    }

    public var currentLog: String {
        guard endLog.isEmpty else {
          return endLog
        }
        let logBattle = setCombatLogAsString()
        if logBattle.isEmpty {
            return actionLog ?? moveLog ?? ""
        }
        return logBattle
    }

    public var currentBuffLog: String {
        return activeBuffs.map { key, buffs in
            let sorted = buffs.sorted(by: { $0.time > $1.time })
            let buffStrings = sorted.map { "\($0.time)s (+\($0.value))" }
            return "\(key): \(buffStrings.joined(separator: ", "))"
        }
        .sorted(by: { $0 < $1 })
        .joined(separator: " | ")
    }

    private func setCombatLogAsString() -> String {
        guard !combatLog.isEmpty else { return "" }
        return combatLog.joined(separator: "\n")
    }
    
    public func saveLogsToFile() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let logFileURL = documentsDirectory.appendingPathComponent(logFileName)
        let logContent = operationLog.joined(separator: "\n")
        try? logContent.write(to: logFileURL, atomically: true, encoding: .utf8)
       }
    
    private func clearLogFile() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let logFileURL = documentsDirectory.appendingPathComponent(logFileName)
        try? FileManager.default.removeItem(at: logFileURL)
      }
}
