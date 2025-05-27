//
//  generateEnemy.swift
//  rogue

// ПЕРЕПИСАТЬ АНАЛОГИЧНО ПРЕДМЕТАМ
enum EnemyFactory {
    static func randomEnemy(for difficulty: GameDifficulty, player: Player, level: Int) -> any EnemyProtocol {
        // Базовые вероятности для каждого типа врага
        var probabilities: [EnemyType: Double] = [
            .zombie: 0.4,
            .vampire: 0.25,
            .ghost: 0.2,
            .ogre: 0.1,
            .snakeMage: 0.05
        ]
        
        // Корректировка в зависимости от уровня
        let levelFactor = Double(level) * 0.03
        probabilities[.zombie]? -= levelFactor
        probabilities[.vampire]? += levelFactor * 0.5
        probabilities[.ogre]? += levelFactor * 0.7
        probabilities[.snakeMage]? += levelFactor * 0.8
        
        // Корректировка в зависимости от сложности
        switch difficulty {
        case .easy:
            probabilities[.zombie]? *= 1.3
            probabilities[.ogre]? *= 0.5
            probabilities[.snakeMage]? *= 0.3
        case .normal:
            break // оставляем базовые вероятности
        case .hard:
            probabilities[.zombie]? *= 0.7
            probabilities[.ogre]? *= 1.5
            probabilities[.snakeMage]? *= 2.0
        }
        
        // Корректировка в зависимости от состояния игрока
        let healthRatio = Double(player.characteristics.health) / Double(player.characteristics.maxHealth)
        if healthRatio < 0.3 {
            // Если у игрока мало здоровья, уменьшаем сложных врагов
            probabilities[.ogre]? *= 0.7
            probabilities[.snakeMage]? *= 0.5
        } else if healthRatio > 0.8 && player.characteristics.strength > 15 {
            // Если игрок сильный, добавляем более сложных врагов
            probabilities[.ogre]? *= 1.3
            probabilities[.snakeMage]? *= 1.5
        }
        
        // Нормализуем вероятности
        let total = probabilities.values.reduce(0, +)
        for (type, _) in probabilities {
            probabilities[type]? /= total
        }
        
        // Выбираем тип врага
        let random = Double.random(in: 0..<1)
        var runningSum = 0.0
        
        for (type, probability) in probabilities {
            runningSum += probability
            if random < runningSum {
                return createEnemy(of: type)
            }
        }
        
        return createEnemy(of: .zombie)
    }
    
    private static func createEnemy(of type: EnemyType) -> any EnemyProtocol {
        // Базовые характеристики
//        let baseStats: (health: Int, agility: Int, strength: Int, hostility: Int)
//        let movementStrategy: MovementStrategy
//        
//        switch type {
//        case .zombie:
//            baseStats = (80, 3, 12, 7)
//            movementStrategy = RandomMovement()
//        case .vampire:
//            baseStats = (60, 15, 10, 9)
//            movementStrategy = HitAndRunMovement()
//        case .ghost:
//            baseStats = (40, 18, 5, 6)
//            movementStrategy = TeleportMovement()
//        case .ogre:
//            baseStats = (120, 2, 25, 5)
//            movementStrategy = AggressiveMovement()
//        case .snakeMage:
//            baseStats = (50, 20, 8, 8)
//            movementStrategy = DiagonalMovement()
//        }
//        
//        // Модификаторы сложности
//        let difficultyMultiplier: Double
//        switch difficulty {
//        case .easy: difficultyMultiplier = 0.8
//        case .normal: difficultyMultiplier = 1.0
//        case .hard: difficultyMultiplier = 1.3
//        }
//        
//        // Модификаторы уровня
//        let levelMultiplier = 1.0 + Double(level) * 0.05
//        
//        // Итоговые характеристики
//        let health = Int(Double(baseStats.health) * difficultyMultiplier * levelMultiplier)
//        let strength = Int(Double(baseStats.strength) * difficultyMultiplier * levelMultiplier)
//        let agility = Int(Double(baseStats.agility) * difficultyMultiplier)
//        
//        let characteristics = Characteristics(
//            position: Position(0, 0),
//            maxHealth: health,
//            health: health,
//            agility: agility,
//            strength:  strength // Позиция будет установлена при размещении
//        )
        
        // Создаем конкретного врага
        switch type {
        case .zombie:
            return Zombie()
        case .vampire:
            return Vampire()
        case .ghost:
            return Ghost()
        case .ogre:
            return Ogre()
        case .snakeMage:
            return SnakeMage()
        }
    }
}

