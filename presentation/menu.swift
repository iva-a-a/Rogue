//
//  menu.swift
//  rogue

public enum MenuAction: Hashable, Equatable, Encodable, CaseIterable {
    case start
    case load
    case leadboard
    case exit
}

public class MenuRender {

    private var selectedIndex = 0
    
    public init() { }

    public func render() {
        renderIcon()
        renderOptions()
        renderSelectionBrackets()
    }
    
    private func renderIcon() {
        var y = 1
        for line in MenuConstants.icon {
            Render.drawTiles(Tile().getDrawableObjectsFromString(str: line,
                                                                 x: MenuConstants.leftPadding,
                                                                 y: y))
            y += 1
        }
    }
    
    private func renderOptions() {
        var y = MenuConstants.icon.count + MenuConstants.downPadding
        for option in MenuConstants.options {
            Render.drawTiles(Tile().getDrawableObjectsFromString(str: option,
                                                                 x: MenuConstants.chooseLeftPadding,
                                                                 y: y))
            y += 2
        }
    }
    
    private func renderSelectionBrackets() {
        let yPosition = MenuConstants.icon.count + MenuConstants.downPadding + selectedIndex * MenuConstants.bracketSpacing
        let selectedOption = MenuConstants.options[selectedIndex]
        
        let leftBracket = Tile(posX: yPosition,posY: MenuConstants.chooseLeftPadding, char: "[")
        let rightBracket = Tile(posX: yPosition, posY: MenuConstants.chooseLeftPadding + selectedOption.count - 1, char: "]")

        leftBracket.draw()
        rightBracket.draw()
    }
    
    public func handleInput(_ action: PlayerAction) -> MenuAction? {
        switch action {
        case .move(dx: -1, dy: 0):
            selectedIndex = max(0, selectedIndex - 1)
            return nil
        case .move(dx: 1, dy: 0):
            selectedIndex = min(MenuConstants.options.count - 1, selectedIndex + 1)
            return nil
        case .start:
            return currentMenuAction
        default:
            return nil
        }
    }

    private var currentMenuAction: MenuAction {
        guard MenuAction.allCases.indices.contains(selectedIndex) else {
            return .start
        }
        return MenuAction.allCases[selectedIndex]
    }
}

enum MenuConstants {
    static let leftPadding = 1
    static let chooseLeftPadding = 55
    static let bracketSpacing = 2
    static let downPadding = 2
    
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
    
    static let options = ["   NEW GAME   ", "   LOAD GAME   ", "   LEADERBOARD   ", "   EXIT   "]
}
