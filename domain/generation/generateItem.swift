//
//  generateItem.swift
//  rogue

enum ItemFactory {
    static func randomItem() -> any Item {
        let itemTypes: [() -> any Item] = [
            { Food(foodType: [.apple, .bread, .meat].randomElement()!) },
            { Scroll(scrollType: [.health, .agility, .strength].randomElement()!) },
            { Elixir(elixirType: [.health, .agility, .strength].randomElement()!, duration: 30) },
            { Weapon(weaponType: [.sword, .bow, .dagger, .staff].randomElement()!) }
        ]
        return itemTypes.randomElement()!()
    }
}
