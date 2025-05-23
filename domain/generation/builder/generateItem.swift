//
//  generateItem.swift
//  rogue

enum ItemFactory {
    static func randomItem(for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        // Базовые вероятности для каждого типа предмета
        var probabilities: [ItemCategory: Double] = [
            .food: 0.35,
            .scroll: 0.25,
            .elixir: 0.2,
            .weapon: 0.15
        ]
        
        // Корректировка в зависимости от уровня
        let levelFactor = Double(level) * 0.02
        probabilities[.food]? -= levelFactor
        probabilities[.scroll]? -= levelFactor * 0.5
        probabilities[.weapon]? += levelFactor * 0.7
        probabilities[.treasure]? += levelFactor * 0.8
        
        // Корректировка в зависимости от сложности
        switch difficulty {
        case .easy:
            probabilities[.food]? *= 1.2
            probabilities[.elixir]? *= 1.1
            probabilities[.weapon]? *= 0.8
        case .normal:
            break // оставляем базовые вероятности
        case .hard:
            probabilities[.food]? *= 0.8
            probabilities[.weapon]? *= 1.2
        }
        
        // Корректировка в зависимости от здоровья игрока
        let healthRatio = Double(player.characteristics.health) / Double(player.characteristics.maxHealth)
        if healthRatio < 0.3 {
            // Если у игрока мало здоровья, увеличиваем шанс еды и зелий
            probabilities[.food]? *= 1.5
            probabilities[.elixir]? *= 1.3
        } else if healthRatio > 0.8 {
            // Если у игрока много здоровья, уменьшаем шанс еды
            probabilities[.food]? *= 0.7
        }
        
        // Нормализуем вероятности (чтобы сумма была = 1)
        let total = probabilities.values.reduce(0, +)
        for (category, _) in probabilities {
            probabilities[category]? /= total
        }
        
        // Выбираем тип предмета
        let random = Double.random(in: 0..<1)
        var runningSum = 0.0
        
        for (category, probability) in probabilities {
            runningSum += probability
            if random < runningSum {
                return generateItem(of: category, for: difficulty, player: player, level: level)
            }
        }
        return Food(foodType: .apple)
    }
    
    private static func generateItem(of category: ItemCategory, for difficulty: GameDifficulty, player: Player, level: Int) -> any ItemProtocol {
        switch category {
        case .food:
            let types: [FoodType]
            switch difficulty {
            case .easy:
                types = [.apple, .bread, .bread] // больше хлеба
            case .normal:
                types = [.apple, .bread, .meat]
            case .hard:
                types = [.bread, .meat, .meat] // больше мяса
            }
            return Food(foodType: types.randomElement()!)
            
        case .scroll:
            let scrollType: ScrollType = {
                // На высоких уровнях чаще даем полезные свитки
                if level > 3 {
                    return [.health, .strength, .agility].randomElement()!
                }
                return .health
            }()
            return Scroll(scrollType: scrollType)
            
        case .elixir:
            let elixirType: ElixirType = {
                let healthRatio = Double(player.characteristics.health) / Double(player.characteristics.maxHealth)
                // Если у игрока мало здоровья, увеличиваем шанс зелья здоровья
                if healthRatio < 0.4 || (difficulty == .hard && healthRatio < 0.6) {
                    return .health
                }
                return [.health, .agility, .strength].randomElement()!
            }()
            
            // Увеличиваем длительность и силу эффекта в зависимости от уровня и сложности
            var duration = Double.random(in: 1...3) * 30
            var effectBonus = 0
            
            if difficulty == .hard {
                duration *= 1.2
                effectBonus += 2
            }
            
            if level > 10 {
                duration *= 1.1
                effectBonus += level / 2
            }
            
            return Elixir(elixirType: elixirType, duration: duration)
            
        case .weapon:
       
            let weaponType: WeaponType = {
                if level > 10 {
                    return [.sword, .bow].randomElement()!
                }
                return [.sword, .bow, .dagger, .staff].randomElement()!
            }()
            return Weapon(weaponType: weaponType)
            
        case .treasure:
            return Treasure(treasureType: .gold)
        }
    }
}
