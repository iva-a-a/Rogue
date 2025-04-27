//
//  constants.swift
//  rogue

enum Constants {
    static let heightMap: Int = 24
    static let widthMap: Int = 80

    static let sectorWidth: Int = widthMap / gridSize
    static let sectorHeight: Int = heightMap / gridSize

    static let minWidthRoom: Int = 6
    static let minHeightRoom: Int = 5

    static let maxWidthRoom: Int = 10
    static let maxHeightRoom: Int = 7

    static let gridSize: Int = 3
}
