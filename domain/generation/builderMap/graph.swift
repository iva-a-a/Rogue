//
//  graph.swift
//  rogue

public struct Graph {
    var adjacencyList: [Int: Set<Int>]
    var connectivity: [Bool]

    init(count: Int = Constants.Graph.countNode) {
        self.adjacencyList = Dictionary(uniqueKeysWithValues: (0..<count).map { ($0, Set()) })
        self.connectivity = Array(repeating: false, count: count)
    }
}

extension Graph {
    mutating func addConnection(from: Int, to: Int) {
        guard isValidNode(from) && isValidNode(to) else { return }
        adjacencyList[from]?.insert(to)
        adjacencyList[to]?.insert(from)
    }

    mutating func dfs(from startNode: Int) {
        guard isValidNode(startNode) else { return }

        connectivity[startNode] = true
        for i in adjacencyList[startNode] ?? [] {
            if !connectivity[i] {
                dfs(from: i)
            }
        }
    }

    mutating func bfs(from startNode: Int) -> Int? {
        guard isValidNode(startNode) else { return nil }
        self.resetConnectivity()
        var queue: [Int] = [startNode]
        connectivity[startNode] = true

        var furthestRoom = startNode
        while !queue.isEmpty {
            let current = queue.removeFirst()
            furthestRoom = current
            for neighbor in adjacencyList[current] ?? [] {
                if !connectivity[neighbor] {
                    connectivity[neighbor] = true
                    queue.append(neighbor)
                }
            }
        }
        return furthestRoom
    }

    mutating func resetConnectivity() {
        connectivity = Array(repeating: false, count: connectivity.count)
    }

    private func isValidNode(_ node: Int) -> Bool {
        return node >= 0 && node < Constants.Graph.countNode
    }
}
