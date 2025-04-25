//
//  constants.swift
//  rogue

enum Constants {
    static let heightMap: Int = 80
    static let widthMap: Int = 24

    static let sectorWidth: Int = widthMap / gridSize
    static let sectorHeight: Int = heightMap / gridSize

    static let minWidthRoom: Int = 4
    static let minHeightRoom: Int = 6

    static let maxWidthRoom: Int = 8
    static let maxHeightRoom: Int = 10

    static let gridSize: Int = 3
}
