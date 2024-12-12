import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	private var input: Input!

	private struct Input {
		let pairs: [Pair]
	}

	private enum Data: Equatable {
		case digit(value: Int)
		case list(items: [Data])
	}

	private struct Packet: Equatable, Comparable {
		let data: [Data]

		static func < (lhs: Packet, rhs: Packet) -> Bool {
			compare(a: lhs.data, b: rhs.data) ?? false
		}

		private static func compare(a: [Data], b: [Data]) -> Bool? {
			for index in 0 ..< a.count {
				if index >= b.count {
					return false
				}

				switch (a[index], b[index]) {
				case (.digit(let aValue), .digit(let bValue)):
					if aValue < bValue {
						return true
					} else if aValue > bValue {
						return false
					}
				case (.list(let aListData), .list(let bListData)):
					if let result = compare(a: aListData, b: bListData) {
						return result
					}
				case (.list(let aListData), .digit(let bValue)):
					let bListData: [Data] = [.digit(value: bValue)]

					if let result = compare(a: aListData, b: bListData) {
						return result
					}
				case (.digit(let aValue), .list(let bListData)):
					let aListData: [Data] = [.digit(value: aValue)]

					if let result = compare(a: aListData, b: bListData) {
						return result
					}
				}
			}

			// left items run out of count first
			if a.count == b.count {
				return nil
			} else {
				return true
			}
		}
	}

	private struct Pair {
		let a: Packet
		let b: Packet

		var isValid: Bool {
			a < b
		}
	}

	init() {}

	func solvePart1() -> Int {
		var sum = 0

		for (index, pair) in input.pairs.enumerated() {
			sum += pair.isValid ? (index + 1) : 0
		}

		return sum
	}

	func solvePart2() -> Int {
		var packets: [Packet] = input.pairs.reduce([]) {
			$0 + [$1.a, $1.b]
		}

		let dividerA: Packet = .init(data: [.list(items: [.digit(value: 2)])])
		let dividerB: Packet = .init(data: [.list(items: [.digit(value: 6)])])

		packets.append(dividerA)
		packets.append(dividerB)

		packets = packets.sorted()

		let indexA = packets.firstIndex(of: dividerA)! + 1
		let indexB = packets.firstIndex(of: dividerB)! + 1

		return indexA * indexB
	}

	func parseInput(rawString: String) {
		let lines = rawString.allLines()

		func parsePacketLine(_ line: String, index: inout Int) -> [Data] {
			var data: [Data] = []

			while index < line.count {
				let char = line[index]

				index += 1

				switch char {
				case "[":
					data.append(.list(items: parsePacketLine(line, index: &index)))
				case "]":
					return data
				case ",":
					break
				default:
					// two digit number (ugly, i know)
					if index < line.count, Int(String(line[index])) != nil {
						data.append(.digit(value: Int(String(line[index - 1 ... index]))!))

						index += 1
					} else {
						data.append(.digit(value: Int(String(char))!))
					}
				}
			}

			return data
		}

		var pairs: [Pair] = []

		for index in stride(from: 0, to: lines.count, by: 2) {
			var lineA = lines[index]
			var lineB = lines[index + 1]

			lineA = String(lineA[1 ..< lineA.count - 1])
			lineB = String(lineB[1 ..< lineB.count - 1])

			var index = 0
			let packetA = Packet(data: parsePacketLine(lineA, index: &index))

			index = 0
			let packetB = Packet(data: parsePacketLine(lineB, index: &index))

			pairs.append(.init(a: packetA, b: packetB))
		}

		input = .init(pairs: pairs)
	}
}
