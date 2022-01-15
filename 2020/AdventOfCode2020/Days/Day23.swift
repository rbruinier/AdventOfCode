import Foundation

final class LoopedLinkedList<Element: Hashable & Equatable> {
    class Node {
        var value: Element

        var next: Node?

        init(value: Element, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    // quick lookup of a node instead of enumerating through all items
    var nodeByValue: [Element: Node] = [:]

    var rootNode: Node? = nil
    var lastNode: Node? = nil

    init(values: [Element] = []) {
        for value in values {
            append(value)
        }
    }

    func append(_ value: Element) {
        let node = Node(value: value, next: rootNode)

        if let lastNode = lastNode {
            lastNode.next = node
        } else {
            rootNode = node

            node.next = node
        }

        lastNode = node

        if nodeByValue[value] != nil {
            fatalError()
        }

        nodeByValue[value] = node
    }

    func removeNextNode(of node: Node) -> Node {
        let nextNode = node.next!

        node.next = nextNode.next!

        if nextNode === rootNode {
            rootNode = node
        }

        nextNode.next = nil

        nodeByValue[nextNode.value] = nil

        return nextNode
    }

    func insertNode(_ node: Node, after afterNode: Node) {
        node.next = afterNode.next
        afterNode.next = node

        if nodeByValue[node.value] != nil {
            fatalError()
        }

        nodeByValue[node.value] = node
    }

    func insertNodes(_ nodes: [Node], after afterNode: Node) {
        for node in nodes.reversed() {
            insertNode(node, after: afterNode)
        }
    }

    func findNode(for value: Element) -> Node? {
        return nodeByValue[value]
    }
}

final class Day23Solver: DaySolver {
    let dayNumber: Int = 23

    private var input: Input!

    private struct Input {
        let cups: [Int]
    }

    private func playRoundLinkedList(cups: LoopedLinkedList<Int>, currentCupValue: inout Int, maxCupValue: Int, moveId: Int) {
        let currentCupNode = cups.findNode(for: currentCupValue)!

        let nodes: [LoopedLinkedList<Int>.Node] = [
            cups.removeNextNode(of: currentCupNode),
            cups.removeNextNode(of: currentCupNode),
            cups.removeNextNode(of: currentCupNode)
        ]

        var newCupValue = currentCupValue
        var newCupNode: LoopedLinkedList<Int>.Node!

        while true {
            newCupValue -= 1

            if newCupValue <= 0 {
                newCupValue = maxCupValue
            }

            if let cupsNewCupNode = cups.findNode(for: newCupValue) {
                newCupNode = cupsNewCupNode

                break
            }
        }

        cups.insertNodes(nodes, after: newCupNode)

        currentCupValue = currentCupNode.next!.value
    }

    private func play(moves: Int, with cups: LoopedLinkedList<Int>, maxValue: Int) -> Int {
        var currentCupValue = input.cups.first!

        for moveId in 1 ... moves {
            playRoundLinkedList(cups: cups, currentCupValue: &currentCupValue, maxCupValue: maxValue, moveId: moveId)
        }

        var currentNode = cups.findNode(for: 1)!

        var finalResult = 0

        for _ in 0 ..< input.cups.count - 1 {
            currentNode = currentNode.next!

            finalResult *= 10
            finalResult += currentNode.value
        }

        return finalResult
    }

    func solvePart1() -> Any {
        let cups = LoopedLinkedList<Int>(values: input.cups)

        return play(moves: 100, with: cups, maxValue: 9)
    }

    func solvePart2() -> Any {
        var cupValues = input.cups

        for index in (input.cups.count + 1) ... 1_000_000 {
            cupValues.append(index)
        }

        let cups = LoopedLinkedList(values: cupValues)

        _ = play(moves: 10_000_000, with: cups, maxValue: 1_000_000)

        let currentNode = cups.findNode(for: 1)!

        return currentNode.next!.value * currentNode.next!.next!.value
    }

    func parseInput(rawString: String) {
        input = .init(cups: [2, 8, 4, 5, 7, 3, 9, 6, 1])
    }
}
