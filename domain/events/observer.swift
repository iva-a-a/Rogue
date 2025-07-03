//
//  observer.swift
//  rogue

public protocol GameEventObserver: AnyObject {
    func didReceiveEvent(event: GameEvent)
}

public class GameEventManager {
    public static let shared = GameEventManager()
    
    private var observers: [GameEventObserver] = []

    private init() {}

    public func addObserver(_ observer: GameEventObserver) {
        observers.append(observer)
    }

    func removeObserver(_ observer: GameEventObserver) {
        observers.removeAll { $0 === observer }
    }

    public func notify(_ event: GameEvent) {
        observers.forEach { $0.didReceiveEvent(event: event) }
    }
}
