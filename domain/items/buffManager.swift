//
//  buffManager.swift
//  rogue

import Foundation

public struct ElixirBuf {
    var statIncrease: Int
    var effectEnd: Date
}

public struct Buffs {
    var maxHealth: [ElixirBuf]
    var agility: [ElixirBuf]
    var strength: [ElixirBuf]
}

public class BuffManager {
    private(set) var buffs: Buffs

    public init() {
        self.buffs = Buffs(maxHealth: [], agility: [], strength: [])
    }

    public func addBuff(for type: ElixirType, value: Int, duration: TimeInterval) {
        let endTime = Date() + duration
        let buf = ElixirBuf(statIncrease: value, effectEnd: endTime)

        switch type {
        case .health:
            buffs.maxHealth.append(buf)
        case .agility:
            buffs.agility.append(buf)
        case .strength:
            buffs.strength.append(buf)
        }
    }

    public func update(player: Player) {
        let now = Date()
        // используем вложенную универсальную функцию и замыкание
        func removeExpired(from list: inout [ElixirBuf], applyChange: (Int) -> Void) {
            // проходим по каждому баффу в списке, удаляем все для которых замыкание возвращает тру
            list.removeAll { buf in
                // проверяем истек ли бафф
                if buf.effectEnd <= now {
                    // убираем ранее добавленное значение
                    applyChange(-buf.statIncrease)
                    return true
                }
                return false
            }
        }
        // удаление баффов для здоровья
        removeExpired(from: &buffs.maxHealth) { change in
            player.characteristics.maxHealth += change
            player.characteristics.health = max(1, min(player.characteristics.health, player.characteristics.maxHealth))
        }
        // удаление баффов для ловкости
        removeExpired(from: &buffs.agility) { change in
            player.characteristics.agility += change
        }
        // удаление баффов для силы
        removeExpired(from: &buffs.strength) { change in
            player.characteristics.strength += change
        }
    }
}

