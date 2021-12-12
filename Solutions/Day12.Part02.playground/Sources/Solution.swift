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
    var canVisitTwice: Bool = false
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

func iteratePath(startNode: Node, endNode: Node) -> [[Node]] {
    var allPaths: [[Node]] = []

    var stack: [[Node]] = [[startNode]]

    while stack.isEmpty == false {
        let path = stack.popLast()!

        let lastNode = path.last!

        if lastNode == endNode {
            allPaths.append(path)

            continue
        }

        for connectingNode in lastNode.connectedNodes {
            if connectingNode.isBig
                || path.contains(connectingNode) == false
                || (connectingNode.canVisitTwice &&  path.filter({ $0 == connectingNode }).count < 2) {
                    stack.append(path + [connectingNode])
            }
        }
    }

    return allPaths
}

public func solutionFor(input: Input) -> Int {
    let smallNodes = input.uniqueNodes.filter { $0.isBig == false && $0 != input.startNode && $0 != input.endNode }


    var allPaths: Set<[Node]> = Set()

    for smallNode in smallNodes {
        print("### ")
        print("### \(smallNode)")
        print("### ")

        smallNode.canVisitTwice = true

        let completedPaths = iteratePath(startNode: input.startNode, endNode: input.endNode)

        completedPaths.forEach {
            allPaths.insert($0)
        }

        print(allPaths.count)

        smallNode.canVisitTwice = false
    }

    return allPaths.count
}
