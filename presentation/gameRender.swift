//
//  gameRender.swift
//  rogue

import Foundation
import Darwin.ncurses

public struct GameScreenView {
    public let tiles: [DrawableObject]
    public let log: String
    public let buffLog: String
    public let info: String

    public init(tiles: [DrawableObject], log: String, buffLog: String, info: String) {
        self.tiles = tiles
        self.log = log
        self.buffLog = buffLog
        self.info = info
    }
}

public struct InventoryView {
    public let header: String
    public let items: [String]
    public let hint: String

    public init(header: String, items: [String], hint: String) {
        self.header = header
        self.items = items
        self.hint = hint
    }
}

public final class GameRenderer {
    public init() {}

    public func renderGameScreen(_ viewModel: GameScreenView) {
        clear()
        Render.drawTiles(viewModel.tiles)

        Render.drawString(String(repeating: " ", count: RenderPadding.length),
                          atY: RenderPadding.infoTop,
                          atX: RenderPadding.zero)
        Render.drawString(viewModel.info,
                          atY: RenderPadding.infoTop,
                          atX: RenderPadding.zero)

        for i in 0..<RenderPadding.logCombatStr {
            Render.drawString(String(repeating: " ", count: RenderPadding.length),
                              atY: RenderPadding.logTop + i,
                              atX: RenderPadding.zero)
        }

        Render.drawString(viewModel.log, atY: RenderPadding.logTop, atX: RenderPadding.zero)

        if !viewModel.buffLog.isEmpty {
            Render.drawString(viewModel.buffLog,
                              atY: RenderPadding.logBuffTop,
                              atX: RenderPadding.zero)
        }
    }

    public func renderInventory(_ viewModel: InventoryView) {
        clear()
        Render.drawString(viewModel.header,
                          atY: RenderPadding.zero,
                          atX: RenderPadding.itemLeft)

        for (i, itemText) in viewModel.items.enumerated() {
            let yPos = RenderPadding.zero + RenderPadding.inventoryAfterTitle + i
            Render.drawString(itemText,
                              atY: yPos,
                              atX: RenderPadding.itemLeft + RenderPadding.itemIndent)
        }

        Render.drawString(viewModel.hint,
                          atY: RenderPadding.zero + RenderPadding.inventoryAfterTitle + viewModel.items.count + RenderPadding.inventoryHintOffset,
                          atX: RenderPadding.itemLeft)
    }
}

private enum RenderPadding {
    static let zero = 0
    static let length = 150

    static let logTop = 27
    static let logBuffTop = 26
    static let logCombatStr = 5

    static let infoTop = 25

    static let itemLeft = 3
    static let itemIndent = 2

    static let inventoryAfterTitle = 2
    static let inventoryHintOffset = 1
}
