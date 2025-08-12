//
//  buffManager.swift
//  rogue

import Foundation

public struct ElixirBuf {
    public var statIncrease: Int
    public var effectEnd: Date
    
    public init(statIncrease: Int, effectEnd: Date) {
        self.statIncrease = statIncrease
        self.effectEnd = effectEnd
    }
}

public struct Buffs {
    public var health: [ElixirBuf]
    public var agility: [ElixirBuf]
    public var strength: [ElixirBuf]
    
    public init(health: [ElixirBuf], agility: [ElixirBuf], strength: [ElixirBuf]) {
        self.health = health
        self.agility = agility
        self.strength = strength
    }
}

public class BuffManager {
    public private(set) var buffs: Buffs

    public init() {
        self.buffs = Buffs(health: [], agility: [], strength: [])
    }
    
    public init (buffs: Buffs) {
        self.buffs = buffs
    }

    public func addBuff(for type: ElixirType, value: Int, duration: TimeInterval) {
        let endTime = Date() + duration
        let buf = ElixirBuf(statIncrease: value, effectEnd: endTime)
        
        var buffName: String = ""
        switch type {
        case .health:
            self.buffs.health.append(buf)
            buffName = "Health Boost"
        case .agility:
            self.buffs.agility.append(buf)
            buffName = "Agility Boost"
        case .strength:
            self.buffs.strength.append(buf)
            buffName = "Strength Boost"
        }
        
        let activeBuffs = (type == .health ? self.buffs.health :
                          type == .agility ? self.buffs.agility :
                          self.buffs.strength)
        let buffInfo = activeBuffs.map { buf in
            BuffInfo(time: Int(buf.effectEnd.timeIntervalSinceNow), value: buf.statIncrease)
        }.filter { $0.time > 0 }

            GameEventManager.shared.notify(.buffUpdate(buffName: buffName, buffInfo: buffInfo))
        }
    
    public func update(player: Player) {
        let now = Date()

        self.processBuffList(list: &self.buffs.health, applyChange: { change in
            player.characteristics.maxHealth += change
            player.characteristics.health = max(1, min(player.characteristics.health + change, player.characteristics.maxHealth))
        }, buffName: "Health Boost", now: now)
        
        self.processBuffList(list: &self.buffs.agility, applyChange: { change in
            player.characteristics.agility += change
        }, buffName: "Agility Boost", now: now)
        
        self.processBuffList(list: &self.buffs.strength, applyChange: { change in
            player.characteristics.strength += change
        }, buffName: "Strength Boost", now: now)
    }

    private func processBuffList(list: inout [ElixirBuf], applyChange: (Int) -> Void, buffName: String, now: Date) {
        let activeBuffs = list.filter { $0.effectEnd > now }
        
        let buffInfo = activeBuffs.map { buf in
            BuffInfo(time: Int(buf.effectEnd.timeIntervalSinceNow), value: buf.statIncrease)
        }.filter { $0.time > 0 }
        
        GameEventManager.shared.notify(.buffUpdate(buffName: buffName, buffInfo: buffInfo))
        
        list.removeAll { buf in
            if buf.effectEnd <= now {
                applyChange(-buf.statIncrease)
                return true
            }
            return false
        }
    }
    
    public func clearAllBuffs() {
        buffs.health.removeAll()
        buffs.agility.removeAll()
        buffs.strength.removeAll()
    }
}
