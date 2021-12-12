import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let paths: [Path] = rawData
        .components(separatedBy: CharacterSet.newlines)
        .filter { $0.isEmpty == false }
        .map {
            let line = $0.components(separatedBy: "-")

            let rawA = line[0]
            let rawB = line[1]

            let a = Node(name: rawA, isBig: rawA[rawA.startIndex].isUppercase, connectedNodes: [])
            let b = Node(name: rawB, isBig: rawB[rawB.startIndex].isUppercase, connectedNodes: [])

            return Path(a: a, b: b)
        }

    let uniqueNodes = Array(Set(paths.flatMap {
        [$0.a, $0.b]
    }))

    uniqueNodes.forEach { node in
        let connectedNodes: [Node] = paths.compactMap { path in
            if path.a == node {
                return uniqueNodes.first(where: { $0.name == path.b.name })!
            } else if path.b == node {
                return uniqueNodes.first(where: { $0.name == path.a.name })!
            }

            return nil
        }

        node.connectedNodes = connectedNodes
    }


    let startNode = uniqueNodes.first(where: { $0.name == "start" })!
    let endNode = uniqueNodes.first(where: { $0.name == "end" })!

    return .init(uniqueNodes: uniqueNodes, startNode: startNode, endNode: endNode)
}
