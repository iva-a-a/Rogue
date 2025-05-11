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
    
    mutating func resetConnectivity() {
        connectivity = Array(repeating: false, count: connectivity.count)
    }
    
    private func isValidNode(_ node: Int) -> Bool {
        return node >= 0 && node < Constants.Graph.countNode
    }
    
    func printGraph() {
        for (room, connect) in adjacencyList {
            let printRoom = room + 1
            let printConnect = connect.map { $0 + 1 }
            print("Комната \(printRoom) соединена с: \(printConnect)")
        }
        for i in connectivity {
            print(i)
        }
    }
}
