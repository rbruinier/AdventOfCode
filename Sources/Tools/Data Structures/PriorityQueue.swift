import Foundation

/**
 See: https://algs4.cs.princeton.edu/24pq/
 */
public struct PriorityQueue<T: Comparable> {
	private var heap: [T] = []
	private let orderFunction: (T, T) -> Bool

	public init(isAscending: Bool = false, initialValues: [T] = []) {
		if isAscending {
			orderFunction = (>)
		} else {
			orderFunction = (<)
		}

		for initialValue in initialValues {
			push(initialValue)
		}
	}

	public mutating func push(_ item: T) {
		heap.append(item)

		swim(heap.count - 1)
	}

	public mutating func pop() -> T? {
		guard heap.isNotEmpty else {
			return nil
		}

		if heap.count == 1 {
			return heap.removeFirst()
		}

		// remove first is slow, instead, items are swapped first
		let newCount = heap.count - 1

		heap.swapAt(0, newCount)

		// re-order
		var index = 0
		var midIndex = (2 * index) + 1

		while midIndex < newCount {
			var swapIndex = midIndex

			if swapIndex < newCount - 1, orderFunction(heap[swapIndex], heap[swapIndex + 1]) {
				swapIndex += 1
			}

			if orderFunction(heap[index], heap[swapIndex]) == false {
				break
			}

			heap.swapAt(index, swapIndex)

			index = swapIndex
			midIndex = (2 * index) + 1
		}

		return heap.removeLast()
	}

	public func peek() -> T? {
		heap.first
	}

	private mutating func swim(_ index: Int) {
		var index = index
		var midIndex = (index - 1) / 2

		while index > 0, orderFunction(heap[midIndex], heap[index]) {
			heap.swapAt(midIndex, index)

			index = midIndex
			midIndex = (index - 1) / 2
		}
	}
}

// MARK: - Collection

extension PriorityQueue: Collection {
	public typealias Index = Int

	public var startIndex: Int { heap.startIndex }
	public var endIndex: Int { heap.endIndex }

	public subscript(i: Int) -> T { heap[i] }

	public func index(after i: Index) -> Index {
		heap.index(after: i)
	}
}

extension PriorityQueue: Sequence {}
