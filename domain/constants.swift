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
        static let width: Int = Map.width / size
        static let height: Int = Map.height / size
    }

    enum Room {
        static let minWidth: Int = 7
        static let minHeight: Int = 6

        static let maxWidth: Int = 12
        static let maxHeight: Int = 9
    }

    enum Graph {
        static let countNode: Int = 9
    }

    static let indent: Int = 1
    static let doorOffset: Int = 2

    enum Item {
        static let maxCount: Int = 9
    }
    
    enum Level {
        static let max: Int = 21
    }
}
