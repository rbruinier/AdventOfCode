import Foundation

/**
 Not yet fully realized (but functional enough) looped linked list for unique values.

 Basically a chain in circular form where every value is unique. This allows for efficient look
 up of a node by value by keeping a dictionary with nodes by value.

 There is some room for optimizations:
    * initializer can be simpler
    * inserting and removing of multiple nodes
 */
public final class LoopedLinkedListSet<Element: Hashable & Equatable> {
    public class Node {
        public var value: Element

        public var next: Node?

        public init(value: Element, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    // quick lookup of a node instead of enumerating through all items
    private var nodeByValue: [Element: Node] = [:]

    private var rootNode: Node? = nil
    private var lastNode: Node? = nil

    public init(values: [Element] = []) {
        for value in values {
            append(value)
        }
    }

    public func append(_ value: Element) {
        let node = Node(value: value, next: rootNode)

        if let lastNode = lastNode {
            lastNode.next = node
        } else {
            rootNode = node

            node.next = node
        }

        lastNode = node

        nodeByValue[value] = node
    }

    public func removeNextNode(of node: Node) -> Node {
        let nextNode = node.next!

        node.next = nextNode.next!

        if nextNode === rootNode {
            rootNode = node
        }

        nextNode.next = nil

        nodeByValue[nextNode.value] = nil

        return nextNode
    }

    public func insertNode(_ node: Node, after afterNode: Node) {
        node.next = afterNode.next
        afterNode.next = node

        nodeByValue[node.value] = node
    }

    public func insertNodes(_ nodes: [Node], after afterNode: Node) {
        for node in nodes.reversed() {
            insertNode(node, after: afterNode)
        }
    }

    public func findNode(for value: Element) -> Node? {
        return nodeByValue[value]
    }
}
