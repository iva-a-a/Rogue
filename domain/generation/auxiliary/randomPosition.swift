//
//  random.swift
//  rogue

struct GetterPositions {

    static func make(in rooms: [Room], excluding: Set<Position>, count: Int, offset: Int) -> [Position] {
        var results: [Position] = []
        var attempts = 0
        let maxAttempts = GenerationConstants.maxPositAttempts * count

        let availableRooms = rooms.enumerated().filter { !$0.element.isStartRoom }
        let roomCount = availableRooms.count

        guard roomCount > 0 else { return [] }

        var positionsPerRoom = Array(repeating: count / roomCount, count: roomCount)
        for i in 0..<(count % roomCount) {
            positionsPerRoom[i] += 1
        }
        var roomPositionCounts = Array(repeating: 0, count: roomCount)

        for (i, roomPair) in availableRooms.enumerated() {
            let room = roomPair.element
            var roomAttempts = 0

            while results.count < count &&
                  roomPositionCounts[i] < positionsPerRoom[i] &&
                  attempts < maxAttempts &&
                  roomAttempts < GenerationConstants.maxPositAttempts {

                let position = randomPositionOnRoom(in: room, offset: offset)
                if !results.contains(position) && !excluding.contains(position) {
                    results.append(position)
                    roomPositionCounts[i] += 1
                }

                attempts += 1
                roomAttempts += 1
            }
        }
        return results
    }
    
    static func randomPositionOnRoom(in room: Room, offset: Int) -> Position {
        Position(
            Int.random(in: room.lowLeft.x + offset...room.topRight.x - offset),
            Int.random(in: room.lowLeft.y + offset...room.topRight.y - offset)
        )
    }
}
