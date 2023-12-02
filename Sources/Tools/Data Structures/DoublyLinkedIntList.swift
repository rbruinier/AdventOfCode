public final class DoublyLinkedIntList: CustomStringConvertible {
	private final class Node {
		var value: Int

		var previous: Node?
		var next: Node?

		init(value: Int) {
			self.value = value
		}

		init(value: Int, previous: Node, next: Node) {
			self.value = value
			self.previous = previous
			self.next = next
		}
	}

	private var rootNode: Node?

	public init(_ values: [Int] = []) {
		for value in values {
			append(value)
		}
	}

	public func append(_ value: Int) {
		if let rootNode {
			let previousNode = rootNode.previous!
			let nextNode = rootNode

			let newNode = Node(value: value, previous: previousNode, next: nextNode)

			previousNode.next = newNode
			nextNode.previous = newNode
		} else {
			let newNode = Node(value: value)

			newNode.previous = newNode
			newNode.next = newNode

			rootNode = newNode
		}
	}

	public func rotate(steps: Int) {
		guard rootNode != nil else {
			return
		}

		if steps > 0 {
			// rotate 1 [0, 1, 2, 3] -> [3, 0, 1, 2]
			var currentNode: Node = rootNode!

			for _ in 0 ..< steps {
				currentNode = currentNode.previous!
			}

			rootNode = currentNode
		} else if steps < 0 {
			// rotate 1 [0, 1, 2, 3] -> [1, 2, 3, 0]
			var currentNode: Node = rootNode!

			for _ in 0 ..< abs(steps) {
				currentNode = currentNode.next!
			}

			rootNode = currentNode
		}
	}

	public func popLast() -> Int? {
		// [0, 1, 2, 3] -> [0, 1, 2]

		guard rootNode != nil else {
			return nil
		}

		let value = rootNode!.previous!.value

		if rootNode! === rootNode!.previous {
			rootNode = nil
		} else {
			rootNode!.previous!.previous!.next = rootNode
			rootNode!.previous = rootNode!.previous!.previous!
		}

		return value
	}

	public var description: String {
		guard let rootNode else {
			return "[]"
		}

		var result = "["

		result += String(rootNode.value)

		var currentNode: Node = rootNode.next!

		while currentNode !== rootNode {
			result += ", " + String(currentNode.value)

			currentNode = currentNode.next!
		}

		return result + "]"
	}
}
