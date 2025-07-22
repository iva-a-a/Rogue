//
//  menu.swift
//  rogue
//
//  unifiedMenu.swift
//  rogue

public enum MenuType {
    case main
    case pause
}

public enum MenuAction: Hashable, Equatable, Encodable {
    case start
    case load
    case leadboard
    case exit
    case resume
    case menu
    
    static func actions(for type: MenuType) -> [MenuAction] {
        switch type {
        case .main:
            return [.start, .load, .leadboard, .exit]
        case .pause:
            return [.resume, .menu, .exit]
        }
    }
}

public class MenuRender {
    private var selectedIndex = 0
    private let type: MenuType
    
    public init(type: MenuType) {
        self.type = type
    }

    public func render() {
        renderIcon()
        renderOptions()
        renderSelectionBrackets()
    }
    
    private func renderIcon() {
        let icon = type == .main ? MenuConstants.icon : MenuConstants.pauseIcon
        var y = 1
        for line in icon {
            Render.drawTiles(Tile().getDrawableObjectsFromString(
                str: line,
                x: MenuConstants.leftPadding,
                y: y
            ))
            y += 1
        }
    }
    
    private func renderTitle(_ title: String) {
        let yPosition = MenuConstants.icon.count + MenuConstants.titlePadding
        let xPosition = MenuConstants.chooseLeftPadding
        
        if !title.isEmpty {
            Render.drawTiles(Tile().getDrawableObjectsFromString(
                str: title,
                x: xPosition,
                y: yPosition
            ))
        }
    }
    
    private func renderOptions() {
        let options = type == .main ? MenuConstants.options : MenuConstants.pauseOptions
        let yStartPosition = MenuConstants.icon.count + MenuConstants.downPadding
        
        for (index, option) in options.enumerated() {
            Render.drawTiles(Tile().getDrawableObjectsFromString(
                str: option,
                x: MenuConstants.chooseLeftPadding,
                y: yStartPosition + index * MenuConstants.bracketSpacing
            ))
        }
    }
    
    private func renderSelectionBrackets() {
        let options = type == .main ? MenuConstants.options : MenuConstants.pauseOptions
        let yStartPosition = MenuConstants.icon.count + MenuConstants.downPadding
        
        let yPosition = yStartPosition + selectedIndex * MenuConstants.bracketSpacing
        let selectedOption = options[selectedIndex]
        
        let leftBracket = Tile(
            posX: yPosition,
            posY: MenuConstants.chooseLeftPadding,
            char: "["
        )
        let rightBracket = Tile(
            posX: yPosition,
            posY: MenuConstants.chooseLeftPadding + selectedOption.count - 1,
            char: "]"
        )

        leftBracket.draw()
        rightBracket.draw()
    }
    
    public func handleInput(_ action: PlayerAction) -> MenuAction? {
        let optionsCount = type == .main ? MenuConstants.options.count : MenuConstants.pauseOptions.count
        
        switch action {
        case .move(dx: -1, dy: 0):
            selectedIndex = max(0, selectedIndex - 1)
            return nil
        case .move(dx: 1, dy: 0):
            selectedIndex = min(optionsCount - 1, selectedIndex + 1)
            return nil
        case .start:
            return currentMenuAction
        default:
            return nil
        }
    }

    private var currentMenuAction: MenuAction {
        let actions = MenuAction.actions(for: type)
        guard actions.indices.contains(selectedIndex) else {
            return type == .main ? .start : .resume
        }
        return actions[selectedIndex]
    }
    
    public func resetSelect() {
        selectedIndex = 0
    }
}

enum MenuConstants {
    static let leftPadding = 1
    static let chooseLeftPadding = 55
    static let bracketSpacing = 2
    static let downPadding = 2
    static let titlePadding = 1
    
    static let icon = [
"          _____                   _______                   _____                    _____                    _____          ",
"         /\\    \\                 /::\\    \\                 /\\    \\                  /\\    \\                  /\\    \\         ",
"        /::\\    \\               /::::\\    \\               /::\\    \\                /::\\____\\                /::\\    \\        ",
"       /::::\\    \\             /::::::\\    \\             /::::\\    \\              /:::/    /               /::::\\    \\       ",
"      /::::::\\    \\           /::::::::\\    \\           /::::::\\    \\            /:::/    /               /::::::\\    \\      ",
"     /:::/\\:::\\    \\         /:::/~~\\:::\\    \\         /:::/\\:::\\    \\          /:::/    /               /:::/\\:::\\    \\     ",
"    /:::/__\\:::\\    \\       /:::/    \\:::\\    \\       /:::/  \\:::\\    \\        /:::/    /               /:::/__\\:::\\    \\    ",
"   /::::\\   \\:::\\    \\     /:::/    / \\:::\\    \\     /:::/    \\:::\\    \\      /:::/    /               /::::\\   \\:::\\    \\   ",
"  /::::::\\   \\:::\\    \\   /:::/____/   \\:::\\____\\   /:::/    / \\:::\\    \\    /:::/    /      _____    /::::::\\   \\:::\\    \\  ",
" /:::/\\:::\\   \\:::\\____\\ |:::|    |     |:::|    | /:::/    /   \\:::\\ ___\\  /:::/____/      /\\    \\  /:::/\\:::\\   \\:::\\    \\ ",
"/:::/  \\:::\\   \\:::|    ||:::|____|     |:::|    |/:::/____/  ___\\:::|    ||:::|    /      /::\\____\\/:::/__\\:::\\   \\:::\\____\\",
"\\::/   |::::\\  /:::|____| \\:::\\    \\   /:::/    / \\:::\\    \\ /\\  /:::|____||:::|____\\     /:::/    /\\:::\\   \\:::\\   \\::/    /",
" \\/____|:::::\\/:::/    /   \\:::\\    \\ /:::/    /   \\:::\\    /::\\ \\::/    /  \\:::\\    \\   /:::/    /  \\:::\\   \\:::\\   \\/____/ ",
"       |:::::::::/    /     \\:::\\    /:::/    /     \\:::\\   \\:::\\ \\/____/    \\:::\\    \\ /:::/    /    \\:::\\   \\:::\\    \\     ",
"       |::|\\::::/    /       \\:::\\__/:::/    /       \\:::\\   \\:::\\____\\       \\:::\\    /:::/    /      \\:::\\   \\:::\\____\\    ",
"       |::| \\::/____/         \\::::::::/    /         \\:::\\  /:::/    /        \\:::\\__/:::/    /        \\:::\\   \\::/    /    ",
"       |::|  ~|                \\::::::/    /           \\:::\\/:::/    /          \\::::::::/    /          \\:::\\   \\/____/     ",
"       |::|   |                 \\::::/    /             \\::::::/    /            \\::::::/    /            \\:::\\    \\         ",
"       \\::|   |                  \\::/____/               \\::::/    /              \\::::/    /              \\:::\\____\\        ",
"        \\:|   |                   ~~                      \\::/____/                \\::/____/                \\::/    /        ",
"         \\|___|                                                                     ~~                       \\/____/         ",
    ]
    
    static let pauseIcon = [
"          _____                    _____                    _____                    _____                    _____          ",
"         /\\    \\                  /\\    \\                  /\\    \\                  /\\    \\                  /\\    \\         ",
"        /::\\    \\                /::\\    \\                /::\\____\\                /::\\    \\                /::\\    \\        ",
"       /::::\\    \\              /::::\\    \\              /:::/    /               /::::\\    \\              /::::\\    \\       ",
"      /::::::\\    \\            /::::::\\    \\            /:::/    /               /::::::\\    \\            /::::::\\    \\      ",
"     /:::/\\:::\\    \\          /:::/\\:::\\    \\          /:::/    /               /:::/\\:::\\    \\          /:::/\\:::\\    \\     ",
"    /:::/__\\:::\\    \\        /:::/__\\:::\\    \\        /:::/    /               /:::/__\\:::\\    \\        /:::/__\\:::\\    \\    ",
"   /::::\\   \\:::\\    \\      /::::\\   \\:::\\    \\      /:::/    /                \\:::\\   \\:::\\    \\      /::::\\   \\:::\\    \\   ",
"  /::::::\\   \\:::\\    \\    /::::::\\   \\:::\\    \\    /:::/    /      _____    ___\\:::\\   \\:::\\    \\    /::::::\\   \\:::\\    \\  ",
" /:::/\\:::\\   \\:::\\____\\  /:::/\\:::\\   \\:::\\    \\  /:::/____/      /\\    \\  /\\   \\:::\\   \\:::\\    \\  /:::/\\:::\\   \\:::\\    \\ ",
"/:::/  \\:::\\   \\:::|    |/:::/  \\:::\\   \\:::\\____\\|:::|    /      /::\\____\\/::\\   \\:::\\   \\:::\\____\\/:::/__\\:::\\   \\:::\\____\\",
"\\::/    \\:::\\  /:::|____|\\::/    \\:::\\  /:::/    /|:::|____\\     /:::/    /\\:::\\   \\:::\\   \\::/    /\\:::\\   \\:::\\   \\::/    /",
" \\/_____/\\:::\\/:::/    /  \\/____/ \\:::\\/:::/    /  \\:::\\    \\   /:::/    /  \\:::\\   \\:::\\   \\/____/  \\:::\\   \\:::\\   \\/____/ ",
"          \\::::::/    /            \\::::::/    /    \\:::\\    \\ /:::/    /    \\:::\\   \\:::\\    \\       \\:::\\   \\:::\\    \\     ",
"           \\::::/    /              \\::::/    /      \\:::\\    /:::/    /      \\:::\\   \\:::\\____\\       \\:::\\   \\:::\\____\\    ",
"            \\::/____/               /:::/    /        \\:::\\__/:::/    /        \\:::\\  /:::/    /        \\:::\\   \\::/    /    ",
"             ~~                    /:::/    /          \\::::::::/    /          \\:::\\/:::/    /          \\:::\\   \\/____/     ",
"                                  /:::/    /            \\::::::/    /            \\::::::/    /            \\:::\\    \\         ",
"                                 /:::/    /              \\::::/    /              \\::::/    /              \\:::\\____\\        ",
"                                 \\::/    /                \\::/____/                \\::/    /                \\::/    /        ",
"                                  \\/____/                  ~~                       \\/____/                  \\/____/         "
    ]

    static let options = ["   NEW GAME   ", "   LOAD GAME   ", "   LEADERBOARD   ", "   EXIT   "]
    static let pauseOptions = ["   CONTINUE   ", "   MAIN MENU   ", "   EXIT   "]
}
