import Foundation
import Tools

final class Day25Solver: DaySolver {
    let dayNumber: Int = 25

	struct Input {
		let keys: [[Int]]
		let locks: [[Int]]
		let totalHeight: Int
	}

	private func isMatch(key: [Int], lock: [Int], totalHeight: Int) -> Bool {
		guard key.count == lock.count else {
			preconditionFailure()
		}
		
		for (keyValue, lockValue) in zip(key, lock) {
			if keyValue + lockValue > totalHeight {
				return false
			}
		}
		
		return true
	}
	
	func solvePart1(withInput input: Input) -> Int {
		let totalHeight = input.totalHeight
		
		var result = 0
		for key in input.keys {
			for lock in input.locks {
				result += isMatch(key: key, lock: lock, totalHeight: totalHeight) ? 1 : 0
			}
		}
		
		return result
	}

	func solvePart2(withInput input: Input) -> Int {
		return 0
	}

	func parseInput(rawString: String) -> Input {
		var keys: [[Int]] = []
		var locks: [[Int]] = []
		
		var currentHeights: [Int: Int] = [:]
		
		var isParsingKey = false
		var currentY = 0
		var totalHeight = 0
		
		for line in rawString.allLines(includeEmpty: true) {
			if line.isEmpty {
				let values = currentHeights.sorted(by: { $0.key < $1.key} ).map(\.value)
				
				if isParsingKey {
					keys.append(values)
				} else {
					locks.append(values)
				}
				
				currentY = 0
				currentHeights.removeAll()
				
				continue
			}
			
			if currentY == 0 {
				isParsingKey = line[0] == "."
			}
			
			for (index, character) in line.enumerated() {
				currentHeights[index, default: 0] += character == "#" ? 1 : 0
			}
			
			currentY += 1
			
			totalHeight = max(totalHeight, currentY)
		}
//		
//		let values = currentHeights.sorted(by: { $0.key < $1.key} ).map(\.value)
//		
//		if isParsingKey {
//			keys.append(values)
//		} else {
//			locks.append(values)
//		}

		return .init(keys: keys, locks: locks, totalHeight: totalHeight)
	}
}
