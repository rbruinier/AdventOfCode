import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	struct Input {
		let boxIDs: [String]
	}

	func solvePart1(withInput input: Input) -> Int {
		var twoCounter = 0
		var threeCounter = 0

		for id in input.boxIDs {
			var counter: [String: Int] = [:]

			for char in id {
				counter[String(char), default: 0] += 1
			}

			twoCounter += Set(counter.values).contains(2) ? 1 : 0
			threeCounter += Set(counter.values).contains(3) ? 1 : 0
		}

		return twoCounter * threeCounter
	}

	func solvePart2(withInput input: Input) -> String {
		for i in 0 ..< input.boxIDs.count {
			for j in i + 1 ..< input.boxIDs.count {
				let a = input.boxIDs[i]
				let b = input.boxIDs[j]

				assert(a.count == b.count)

				var differenceIndex: Int?
				for k in 0 ..< a.count {
					if a[k] != b[k] {
						if differenceIndex != nil {
							differenceIndex = nil

							break
						}

						differenceIndex = k
					}
				}

				if let differenceIndex {
					var characters = a.map { String($0) }

					characters.remove(at: differenceIndex)

					return characters.joined()
				}
			}
		}

		fatalError()
	}

	func parseInput(rawString: String) -> Input {
		return .init(boxIDs: rawString.allLines())
	}
}
