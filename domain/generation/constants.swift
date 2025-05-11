//
//  constants.swift
//  rogue

enum Constants {
    enum Map {
        static let height: Int = 24
        static let width: Int = 80
    }
    enum Grid {
        static let size: Int = 3
        static let sectorWidth: Int = Map.width / size
        static let sectorHeight: Int = Map.height / size
    }
    
    enum Room {
        static let minWidth: Int = 6
        static let minHeight: Int = 5

        static let maxWidth: Int = 10
        static let maxHeight: Int = 7
    }
    
    enum Graph {
        static let countNode: Int = 9
    }

    static let indent: Int = 1
    static let stepForDoor: Int = 2
}
