import Foundation

public struct Input {
    let uniqueNodes: [Node]
    let startNode: Node
    let endNode: Node
}

public struct Path: Equatable, Hashable {
    let a: Node
    let b: Node
}

public class Node: CustomDebugStringConvertible, Equatable, Hashable {
    let name: String
    let isBig: Bool
    var connectedNodes: [Node]

    public var debugDescription: String {
        return "\(name), connects to: [\(connectedNodes.map { $0.name })]"
    }

    public init(name: String, isBig: Bool, connectedNodes: [Node]) {
        self.name = name
        self.isBig = isBig
        self.connectedNodes = connectedNodes
    }

    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

func iteratePaths(node: Node, path: inout [Node], startNode: Node, endNode: Node, completedPaths: inout [[Node]]) {
    print("Handling: \(node.debugDescription)")

    path.append(node)

    guard node != endNode else {
        completedPaths.append(path)

        return
    }

    for connectedNode in node.connectedNodes {
        guard connectedNode.isBig || (path.contains(connectedNode) == false) else {
            continue
        }

        var pathSoFar = path

        iteratePaths(node: connectedNode, path: &pathSoFar, startNode: startNode, endNode: endNode, completedPaths: &completedPaths)
    }
}

public func solutionFor(input: Input) -> Int {
    var completedPaths: [[Node]] = []

    for connectedNode in input.startNode.connectedNodes {
        var path: [Node] = [input.startNode]

        iteratePaths(node: connectedNode, path: &path, startNode: input.startNode, endNode: input.endNode, completedPaths: &completedPaths)
    }

    return completedPaths.count
}
