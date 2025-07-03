//
//  gameEvent.swift
//  rogue

public struct BuffInfo: Equatable {
    let time: Int
    let value: Int
}

public enum GameEvent: Equatable {
    case playerMissed(target: String)
    case playerSleep
    case playerSkipMove
    case playerHit(target: String, damage: Int, remainingHealth: Int)
    case enemyMissed(enemy: String)
    case enemyHit(enemy: String, damage: Int)
    case enemyDefeated(enemy: String)
    case itemPickedUp(item: String)
    case notPickedUp
    case weaponDropped(weapon: String)
    case playerMoved(to: Position)
    case playerNotMoved
    case eatFood(food: String, amount: Int)
    case drinkElixir(elixir: String, duration: Int)
    case readScroll(scroll: String, amount: Int)
    case useWeapon(weapon: String, damage: Int)
    case pickUpTreasure(treasure: String, amount: Int)
    case openColorDoor(color: String)
    case notOpenColorDoor
    case levelComplete(number: Int)
    case gameOver
    case gameWon
    case buffUpdate(buffName: String, buffInfo: [BuffInfo])
    case saveStats
    case notSaveStats
}

