//
//  gameEvent.swift
//  rogue

enum GameEvent {
    case playerMissed(target: String)
    case playerSleep
    case playerSkipMove
    case playerHit(target: String, damage: Int)
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
}

