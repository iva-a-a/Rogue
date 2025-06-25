//
//  gameState.swift
//  rogue

public enum GameState {
    case beginning
    // добавить загрузку из файла
    case generating
    case playing
    case inventory
    case levelComplete
    case won
    case lose
    case quit
}
