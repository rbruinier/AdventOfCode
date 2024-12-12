import Foundation

public extension ArraySlice {
	func combinationsWithoutRepetition(length: Int) -> [[Element]] {
		guard count >= length else {
			return []
		}

		guard count >= length, length > 0 else {
			return [[]]
		}

		if length == 1 {
			return map { [$0] }
		}

		var combinations = [[Element]]()

		for (index, element) in enumerated() {
			combinations += dropFirst(index + 1).combinationsWithoutRepetition(length: length - 1).map {
				[element] + $0
			}
		}

		return combinations
	}
}

public extension Array {
	/**
	 Returns all permutations of an array.

	 See: https://en.wikipedia.org/wiki/Heap%27s_algorithm
	 */
	var permutations: [[Element]] {
		var stack = [Int](repeating: 0, count: count)

		var items = self
		var permutations: [[Element]] = [self]

		var i = 0
		while i < count {
			if stack[i] < i {
				if i & 1 == 0 {
					items.swapAt(0, i)
				} else {
					items.swapAt(stack[i], i)
				}

				permutations.append(items)

				stack[i] += 1
				i = 0
			} else {
				stack[i] = 0
				i += 1
			}
		}

		return permutations
	}

	func subsets(minLength: Int, maxLength: Int) -> [[Element]] {
		var subsets: [[Element]] = []

		for length in minLength ... maxLength {
			if length == 0 {
				subsets.append([])
			} else if length == 1 {
				subsets.append(contentsOf: map { [$0] })
			} else if length == 2 {
				for startIndex in 0 ..< count - (length - 1) {
					for item in self[startIndex + 1 ..< count] {
						subsets.append([self[startIndex], item])
					}
				}
			} else {
				fatalError("Not yet implemented")
			}
		}

		return subsets
	}

	func combinationsWithoutRepetition(length: Int) -> [[Element]] {
		ArraySlice(self).combinationsWithoutRepetition(length: length)
	}
}
