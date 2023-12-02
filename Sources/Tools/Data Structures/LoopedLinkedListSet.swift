import Foundation

/**
 Not yet fully realized (but functional enough) looped linked list for unique values.

 Basically a chain in circular form where every value is unique. This allows for efficient look
 up of a node by value by keeping a dictionary with nodes by value.

 There is some room for optimizations:
    * initializer can be simpler
    * inserting and removing of multiple nodes

 Note: because this type is a separate module we use the specialize attribute to optimize it for specific
 types. See also: https://github.com/apple/swift/blob/main/docs/Generics.rst#specialization
 */
public final class LoopedLinkedListSet<Element: Hashable & Equatable> {
	public class Node {
		public var value: Element

		public var next: Node?

		@_specialize(exported: true, kind: full, where Element == Int)
		public init(value: Element, next: Node? = nil) {
			self.value = value
			self.next = next
		}
	}

	// quick lookup of a node instead of enumerating through all items
	private var nodeByValue: [Element: Node] = [:]

	private var rootNode: Node?
	private var lastNode: Node?

	@_specialize(exported: true, kind: full, where Element == Int)
	public init(values: [Element] = []) {
		for value in values {
			append(value)
		}
	}

	@_specialize(exported: true, kind: full, where Element == Int)
	public func append(_ value: Element) {
		let node = Node(value: value, next: rootNode)

		if let lastNode {
			lastNode.next = node
		} else {
			rootNode = node

			node.next = node
		}

		lastNode = node

		nodeByValue[value] = node
	}

	@_specialize(exported: true, kind: full, where Element == Int)
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

	@_specialize(exported: true, kind: full, where Element == Int)
	public func insertNode(_ node: Node, after afterNode: Node) {
		node.next = afterNode.next
		afterNode.next = node

		nodeByValue[node.value] = node
	}

	@_specialize(exported: true, kind: full, where Element == Int)
	public func insertNodes(_ nodes: [Node], after afterNode: Node) {
		for node in nodes.reversed() {
			insertNode(node, after: afterNode)
		}
	}

	@_specialize(exported: true, kind: full, where Element == Int)
	public func findNode(for value: Element) -> Node? {
		nodeByValue[value]
	}
}
