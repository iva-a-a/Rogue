//
//  generateItem.swift
//  rogue

enum ItemFactory {
    static func randomItem() -> any ItemProtocol {
        let itemTypes: [() -> any ItemProtocol] = [
            { Food(foodType: [.apple, .bread, .meat].randomElement()!) },
            { Scroll(scrollType: [.health, .agility, .strength].randomElement()!) },
            { Elixir(elixirType: [.health, .agility, .strength].randomElement()!, duration: Double.random(in: 1...4) * 30) },
            { Weapon(weaponType: [.sword, .bow, .dagger, .staff].randomElement()!) }
        ]
        return itemTypes.randomElement()!()
    }
}
