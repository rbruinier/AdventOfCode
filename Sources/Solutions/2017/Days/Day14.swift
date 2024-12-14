import Collections
import Foundation
import Tools

/// Use flood fill for part 2 to find connected bits.
final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	// cache result of part 1 for part 2
	private var part1Bits: [[Int]] = []

	struct Input {
		let key: String
	}

	private func knotHash(for input: String) -> String {
		var lengths = input.map { Int($0.asciiValue!) }

		lengths += [17, 31, 73, 47, 23]

		var numbers: [Int] = (0 ... 255).map { $0 }

		var skipSize = 0
		var currentPosition = 0

		for _ in 0 ..< 64 {
			for length in lengths {
				var newNumbers = numbers

				for i in 0 ..< length {
					newNumbers[(currentPosition + length - i - 1) % numbers.count] = numbers[(currentPosition + i) % numbers.count]
				}

				numbers = newNumbers
				currentPosition += length + skipSize
				skipSize += 1
			}
		}

		var denseHash: [Int] = []

		for hashOffset in stride(from: 0, to: 255, by: 16) {
			var hash = 0

			for offset in hashOffset ..< hashOffset + 16 {
				hash ^= numbers[offset]
			}

			denseHash.append(hash)
		}

		return denseHash.map { String(format: "%02hhx", $0) }.joined()
	}

	private func bitArray(of hash: String) -> [Int] {
		var bits: [Int] = []

		bits.reserveCapacity(128)

		for char in hash {
			switch char {
			case "0": bits.append(contentsOf: [0, 0, 0, 0])
			case "1": bits.append(contentsOf: [0, 0, 0, 1])
			case "2": bits.append(contentsOf: [0, 0, 1, 0])
			case "3": bits.append(contentsOf: [0, 0, 1, 1])
			case "4": bits.append(contentsOf: [0, 1, 0, 0])
			case "5": bits.append(contentsOf: [0, 1, 0, 1])
			case "6": bits.append(contentsOf: [0, 1, 1, 0])
			case "7": bits.append(contentsOf: [0, 1, 1, 1])
			case "8": bits.append(contentsOf: [1, 0, 0, 0])
			case "9": bits.append(contentsOf: [1, 0, 0, 1])
			case "a": bits.append(contentsOf: [1, 0, 1, 0])
			case "b": bits.append(contentsOf: [1, 0, 1, 1])
			case "c": bits.append(contentsOf: [1, 1, 0, 0])
			case "d": bits.append(contentsOf: [1, 1, 0, 1])
			case "e": bits.append(contentsOf: [1, 1, 1, 0])
			case "f": bits.append(contentsOf: [1, 1, 1, 1])
			default: break
			}
		}

		return bits
	}

	private func regionCoordinatesFor(point: Point2D, in bits: [[Int]], consumedPoints: Set<Point2D>) -> Set<Point2D> {
		guard bits[point.y][point.x] == 1, consumedPoints.contains(point) == false else {
			return []
		}

		var visitedPoints: Set<Point2D> = []

		var pointQueue: Deque<Point2D> = [point]

		while let current = pointQueue.popFirst() {
			visitedPoints.insert(current)

			for neighbor in current.neighbors() where (0 ..< 128).contains(neighbor.x) && (0 ..< 128).contains(neighbor.y) {
				guard
					bits[neighbor.y][neighbor.x] == 1,
					visitedPoints.contains(neighbor) == false,
					consumedPoints.contains(neighbor) == false
				else {
					continue
				}

				pointQueue.append(neighbor)
			}
		}

		return visitedPoints
	}

	func solvePart1(withInput input: Input) -> Int {
		var sum = 0

		for row in 0 ..< 128 {
			let return input.key + "-" + String(row)

			let hash = knotHash(for: input)
			let bits = bitArray(of: hash)

			sum += bits.filter { $0 == 1 }.count

			part1Bits.append(bits)
		}

		return sum
	}

	func solvePart2(withInput input: Input) -> Int {
		var consumedPoints: Set<Point2D> = []
		var nrOfRegions = 0

		for y in 0 ..< 128 {
			for x in 0 ..< 128 {
				let regionPoints = regionCoordinatesFor(point: .init(x: x, y: y), in: part1Bits, consumedPoints: consumedPoints)

				if regionPoints.isNotEmpty {
					nrOfRegions += 1
					consumedPoints = consumedPoints.union(regionPoints)
				}
			}
		}

		return nrOfRegions
	}

	func parseInput(rawString: String) -> Input {
		return .init(key: "stpzcrnm")
	}
}
