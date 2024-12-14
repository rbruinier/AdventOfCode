import Foundation
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	struct Input {
		let unfilteredPartNumbers: [PartNumber]
		let symbols: [Symbol]
	}

	struct PartNumber {
		let startPosition: Point2D
		let endPosition: Point2D

		let number: Int

		let positions: Set<Point2D>
		let neighborPositions: Set<Point2D>

		init(startPosition: Point2D, endPosition: Point2D, number: Int) {
			self.startPosition = startPosition
			self.endPosition = endPosition
			self.number = number

			positions = Self.getPositions(withStartPosition: startPosition, endPosition: endPosition)
			neighborPositions = Self.getNeighborPositions(withPositions: positions)
		}

		private static func getPositions(withStartPosition startPosition: Point2D, endPosition: Point2D) -> Set<Point2D> {
			var positions: Set<Point2D> = []

			for x in startPosition.x ... endPosition.x {
				positions.insert(.init(x: x, y: startPosition.y))
			}

			return positions
		}

		private static func getNeighborPositions(withPositions positions: Set<Point2D>) -> Set<Point2D> {
			var neighbors: Set<Point2D> = []

			for position in positions {
				neighbors = neighbors.union(position.neighbors(includingDiagonals: true))
			}

			return neighbors
		}
	}

	struct Symbol {
		let position: Point2D
		let symbol: String
	}

	private func filterPartNumbers(_ partNumbers: [PartNumber], withSymbols symbols: [Symbol]) -> [PartNumber] {
		let symbolPositions: Set<Point2D> = Set(symbols.map(\.position))

		let filteredPartNumbers = partNumbers.filter { partNumber in
			partNumber.neighborPositions.contains { symbolPositions.contains($0) }
		}

		return filteredPartNumbers
	}

	func solvePart1(withInput input: Input) -> Int {
		let filteredPartNumbers = filterPartNumbers(input.unfilteredPartNumbers, withSymbols: input.symbols)

		return filteredPartNumbers.map(\.number).reduce(0, +)
	}

	func solvePart2(withInput input: Input) -> Int {
		let filteredPartNumbers = filterPartNumbers(input.unfilteredPartNumbers, withSymbols: input.symbols)
		let gears = input.symbols.filter { $0.symbol == "*" }

		return gears.reduce(0) { result, gear in
			let matchingPartNumbers = filteredPartNumbers.filter { partNumber in
				partNumber.neighborPositions.contains(gear.position)
			}

			if matchingPartNumbers.count == 2 {
				return result + (matchingPartNumbers[0].number * matchingPartNumbers[1].number)
			} else {
				return result
			}
		}
	}

	func parseInput(rawString: String) -> Input {
		var partNumbers: [PartNumber] = []
		var symbols: [Symbol] = []

		for (y, line) in rawString.allLines().enumerated() {
			var currentNumber: Int? = nil
			var startPosition: Point2D? = nil

			for (x, char) in line.enumerated() {
				if let digit = Int(String(char)) {
					if currentNumber != nil {
						currentNumber = (currentNumber! * 10) + digit
					} else {
						currentNumber = digit
						startPosition = .init(x: x, y: y)
					}
				} else {
					if let currentNumber, let startPosition {
						partNumbers.append(.init(
							startPosition: startPosition,
							endPosition: .init(x: x - 1, y: y),
							number: currentNumber
						))
					}

					currentNumber = nil
					startPosition = nil

					if char != "." {
						symbols.append(.init(position: .init(x: x, y: y), symbol: String(char)))
					}
				}
			}

			if let currentNumber, let startPosition {
				partNumbers.append(.init(
					startPosition: startPosition,
					endPosition: .init(x: line.count - 1, y: y),
					number: currentNumber
				))
			}
		}

		// note: if the last characters on the last line make up a number we miss it but this does not seem the case in the input

		return .init(unfilteredPartNumbers: partNumbers, symbols: symbols)
	}
}
