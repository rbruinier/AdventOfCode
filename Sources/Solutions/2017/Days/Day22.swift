import Foundation
import Tools

final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	struct Input {
		var initialSize: Size
		var infectedNodes: Set<Point2D>
	}

	func solvePart1(withInput input: Input) -> Int {
		var currentPosition = Point2D(x: input.initialSize.width / 2, y: input.initialSize.height / 2)
		var currentDirection = Direction.north

		var infectedNodes = input.infectedNodes

		var numberOfInfections = 0
		for _ in 0 ..< 10000 {
			let isInfected = infectedNodes.contains(currentPosition)

			if isInfected {
				currentDirection = currentDirection.turned(degrees: .ninety)
				infectedNodes.remove(currentPosition)
			} else {
				currentDirection = currentDirection.turned(degrees: .twoSeventy)
				infectedNodes.insert(currentPosition)

				numberOfInfections += 1
			}

			currentPosition = currentPosition.moved(to: currentDirection)
		}

		return numberOfInfections
	}

	func solvePart2(withInput input: Input) -> Int {
		enum State {
			case clean
			case weakened
			case infected
			case flagged
		}

		var currentPosition = Point2D(x: input.initialSize.width / 2, y: input.initialSize.height / 2)
		var currentDirection = Direction.north

		var nodeStates: [Point2D: State] = [:]

		for infectedNode in input.infectedNodes {
			nodeStates[infectedNode] = .infected
		}

		var numberOfInfections = 0
		for _ in 0 ..< 10_000_000 {
			let state: State = nodeStates[currentPosition] ?? .clean

			switch state {
			case .clean:
				currentDirection = currentDirection.turned(degrees: .twoSeventy)
				nodeStates[currentPosition] = .weakened
			case .weakened:
				nodeStates[currentPosition] = .infected
				numberOfInfections += 1
			case .infected:
				currentDirection = currentDirection.turned(degrees: .ninety)
				nodeStates[currentPosition] = .flagged

			case .flagged:
				currentDirection = currentDirection.opposite
				nodeStates.removeValue(forKey: currentPosition)
			}

			currentPosition = currentPosition.moved(to: currentDirection)
		}

		return numberOfInfections
	}

	func parseInput(rawString: String) -> Input {
		let allLines = rawString.allLines()

		var infectedNodes: Set<Point2D> = []

		let height = allLines.count
		let width = allLines.first!.count

		for (y, line) in allLines.enumerated() {
			for (x, char) in line.enumerated() {
				if char == "#" {
					infectedNodes.insert(.init(x: x, y: y))
				}
			}
		}

		return .init(initialSize: .init(width: width, height: height), infectedNodes: infectedNodes)
	}
}
