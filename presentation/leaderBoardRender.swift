//
//  leaderBoardRender.swift
//  rogue

public struct LeaderboardView {
    public let treasure: Int
    public let levelsCompleted: Int
    public let enemiesDefeated: Int
    public let food: Int
    public let elixirs: Int
    public let scrolls: Int
    public let attacks: Int
    public let missed: Int
    public let tiles: Int
    
    public init(treasure: Int, levelsCompleted: Int, enemiesDefeated: Int,
                food: Int, elixirs: Int, scrolls: Int, attacks: Int,
                missed: Int, tiles: Int) {
        self.treasure = treasure
        self.levelsCompleted = levelsCompleted
        self.enemiesDefeated = enemiesDefeated
        self.food = food
        self.elixirs = elixirs
        self.scrolls = scrolls
        self.attacks = attacks
        self.missed = missed
        self.tiles = tiles
        
    }
}

public class LeaderboardRenderer {
    private var currentOffset = 0
    private var allAttempts: [LeaderboardView] = []
    
    public init() {}

    public func render(attempts: [LeaderboardView]) {
        self.allAttempts = attempts
        renderVisibleAttempts()
    }
    
    public func handleInput(_ action: PlayerAction) {
        switch action {
        case .move(dx: 1, dy: 0): scrollDown()
        case .move(dx: -1, dy: 0): scrollUp()
        default: break
        }
    }
    
    private func scrollDown() {
        if currentOffset + LeaderboardConstants.maxAttempts < allAttempts.count {
            currentOffset += 1
            renderVisibleAttempts()
        }
    }
    
    private func scrollUp() {
        if currentOffset > 0 {
            currentOffset -= 1
            renderVisibleAttempts()
        }
    }
    
    private func renderVisibleAttempts() {
        renderTitle()
        guard !allAttempts.isEmpty else {
            renderEmptyMessage()
            return
        }
        let visibleAttempts = Array(allAttempts[currentOffset..<min(currentOffset + LeaderboardConstants.maxAttempts, allAttempts.count)])
        renderHeader()
        renderSeparator()
        renderAttempts(attempts: visibleAttempts)
        renderScrollHint()
    }
    
    private func renderTitle() {
        Render.drawTiles(Tile().getDrawableObjectsFromString(str: LeaderboardConstants.title,
                                                             x: LeaderboardConstants.leftPadding,
                                                             y: LeaderboardConstants.topPadding))
    }
    
    private func renderEmptyMessage() {
        Render.drawTiles(Tile().getDrawableObjectsFromString(str: LeaderboardConstants.noRecords,
                                                             x: LeaderboardConstants.leftPadding,
                                                             y: LeaderboardConstants.topPadding + 2))
        Render.drawTiles(Tile().getDrawableObjectsFromString(str: LeaderboardConstants.noRecordsHint,
                                                             x: LeaderboardConstants.leftPadding,
                                                             y: LeaderboardConstants.topPadding + 4))
    }
    
    private func renderHeader() {
        var headerRow = ""
        for (index, title) in LeaderboardConstants.headerTitles.enumerated() {
            headerRow += title.paddingToLength(LeaderboardConstants.columnWidths[index], withPad: " ")
            if index < LeaderboardConstants.headerTitles.count - 1 {
                headerRow += LeaderboardConstants.spaces
            }
        }
        Render.drawTiles(Tile().getDrawableObjectsFromString(str: headerRow,
                                                             x: LeaderboardConstants.leftPadding,
                                                             y: LeaderboardConstants.topPadding + 2))
    }
    
    private func renderSeparator() {
        Render.drawTiles(Tile().getDrawableObjectsFromString(str: LeaderboardConstants.separator,
                                                             x: LeaderboardConstants.leftPadding,
                                                             y: LeaderboardConstants.topPadding + 3))
    }
    
    private func renderAttempts(attempts: [LeaderboardView]) {
        for (index, attempt) in attempts.enumerated() {
            let values = [
                "\(currentOffset + index + 1)",
                "\(attempt.treasure)",
                "\(attempt.levelsCompleted)",
                "\(attempt.enemiesDefeated)",
                "\(attempt.food)",
                "\(attempt.elixirs)",
                "\(attempt.scrolls)",
                "\(attempt.tiles)"
            ]
            
            var row = ""
            for (valueIndex, value) in values.enumerated() {
                row += value.paddingToLength(LeaderboardConstants.columnWidths[valueIndex], withPad: " ")
                if valueIndex < values.count - 1 {
                    row += LeaderboardConstants.spaces
                }
            }
            Render.drawTiles(Tile().getDrawableObjectsFromString(str: row,
                                                                 x: LeaderboardConstants.leftPadding,
                                                                 y: LeaderboardConstants.topPadding + 4 + index))
        }
    }
    
    private func renderScrollHint() {
        Render.drawTiles(Tile().getDrawableObjectsFromString(str: LeaderboardConstants.hint,
                                                             x: LeaderboardConstants.leftPadding,
                                                             y: LeaderboardConstants.topPadding + 15))
    }

    public func resetOffset() {
        currentOffset = 0
    }
}
enum LeaderboardConstants {
    static let columnSpacing = 2
    static let leftPadding = 4
    static let topPadding = 2
    static let separatorLength = 75
    static let maxAttempts = 10
    static let separator = String(repeating: "-", count: separatorLength)
    static let spaces = String(repeating: " ", count: columnSpacing)
    
    static let title = "LEADERBOARD"
    static let noRecords = "No records yet - be the first!"
    static let noRecordsHint = "Press Esc to return"
    static let headerTitles = ["Rank", "Treasure", "Levels", "Kills", "Food", "Elixirs", "Scrolls", "Tiles"]
    static let columnWidths = [6, 10, 8, 8, 8, 8, 8, 8]
    static let hint = "Press w/s to scroll, Esc to return"
}

extension String {
    func paddingToLength(_ newLength: Int, withPad padString: String) -> String {
        let currentLength = self.count
        guard currentLength < newLength else { return self }
        
        let paddingLength = newLength - currentLength
        let padding = String(repeating: padString, count: paddingLength)
        return self + padding
    }
}
