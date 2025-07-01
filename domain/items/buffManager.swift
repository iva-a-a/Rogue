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
        
        var buffName: String = ""
            switch type {
            case .health:
                self.buffs.maxHealth.append(buf)
                buffName = "Health Boost"
            case .agility:
                self.buffs.agility.append(buf)
                buffName = "Agility Boost"
            case .strength:
                self.buffs.strength.append(buf)
                buffName = "Strength Boost"
            }

            GameEventManager.shared.notify(.buffUpdate(buffName: buffName,
                                                       remainingTime: Int(duration)))
    }
    
    public func update(player: Player) {
        let now = Date()

        self.processBuffList(list: &self.buffs.maxHealth, applyChange: { change in
            player.characteristics.maxHealth += change
            player.characteristics.health = max(1, min(player.characteristics.health, player.characteristics.maxHealth))
        }, buffName: "Health Boost", now: now)
        
        self.processBuffList(list: &self.buffs.agility, applyChange: { change in
            player.characteristics.agility += change
        }, buffName: "Agility Boost", now: now)
        
        self.processBuffList(list: &self.buffs.strength, applyChange: { change in
            player.characteristics.strength += change
        }, buffName: "Strength Boost", now: now)
    }
    
    private func processBuffList(list: inout [ElixirBuf], applyChange: (Int) -> Void, buffName: String, now: Date) {
        for buf in list {
            let remainingTime = Int(buf.effectEnd.timeIntervalSince(now))
            GameEventManager.shared.notify(.buffUpdate(buffName: buffName,
                                                       remainingTime: max(0, remainingTime)))
        }

        list.removeAll { buf in
            if buf.effectEnd <= now {
                applyChange(-buf.statIncrease)
                return true
            }
            return false
        }
    }
}
