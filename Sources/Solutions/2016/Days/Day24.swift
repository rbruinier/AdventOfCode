import Collections
import Foundation
import Tools

/// Two step solution where we first find the distance between all numbers (paths) basically building a graph and then perform a second iteration to find the shortest path
final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	private var input: Input!

	private typealias Grid = [Point2D: Node]

	private struct Input {
		let grid: Grid
	}

	private enum Node: Equatable {
		case wall
		case free
		case position(number: Int)
	}

	private struct Path: Hashable {
		let a: Int
		let b: Int
	}

	private var allPaths: [Path: Int]!
	private var allNumbers: [Int]!

	private func possibleNextPositions(for position: Point2D, grid: Grid) -> [Point2D] {
		position.neighbors().filter { point in
			grid[point] != .wall
		}
	}

	private func position(of number: Int, in grid: Grid) -> Point2D {
		grid.first(where: { _, value in
			value == .position(number: number)
		})!.key
	}

	private func minimumNumberOfRequiredSteps(from pointA: Point2D, to pointB: Point2D, in grid: Grid) -> Int {
		struct Solution {
			let currentPosition: Point2D
			let numberOfSteps: Int
		}

		var solutionQueue: Deque<Solution> = [
			.init(currentPosition: pointA, numberOfSteps: 0),
		]

		var bestSolution: Solution?

		var visitedPoints: Set<Point2D> = [pointA]

		while let solution = solutionQueue.popFirst() {
			if solution.currentPosition == pointB {
				if let currentBestSolution = bestSolution {
					if solution.numberOfSteps < currentBestSolution.numberOfSteps {
						bestSolution = solution
					}
				} else {
					bestSolution = solution
				}
			}

			if let currentBestSolution = bestSolution {
				// optimization: no need to complete a path that is already equal or longer as best found path so far
				if solution.numberOfSteps >= currentBestSolution.numberOfSteps {
					continue
				}
			}

			let possiblePoints = possibleNextPositions(for: solution.currentPosition, grid: grid)

			for nextPoint in possiblePoints where visitedPoints.contains(nextPoint) == false {
				visitedPoints.insert(nextPoint)

				switch grid[nextPoint] {
				case .none,
				     .wall:
					fatalError()
				case .free,
				     .position:
					solutionQueue.append(
						.init(
							currentPosition: nextPoint,
							numberOfSteps: solution.numberOfSteps + 1
						)
					)
				}
			}
		}

		return bestSolution!.numberOfSteps
	}

	private func allPaths(for numbers: [Int], in grid: Grid) -> [Path: Int] {
		var paths: [Path: Int] = [:]

		for i in 0 ..< numbers.count {
			let pointA = position(of: numbers[i], in: grid)

			for j in i + 1 ..< numbers.count {
				let pointB = position(of: numbers[j], in: grid)

				let steps = minimumNumberOfRequiredSteps(from: pointA, to: pointB, in: grid)

				paths[.init(a: numbers[i], b: numbers[j])] = steps
				paths[.init(a: numbers[j], b: numbers[i])] = steps
			}
		}

		return paths
	}

	private func minimumNumberOfRequiredSteps(startingAt startNumber: Int, with numbers: [Int], paths: [Path: Int], returnToStart: Bool = false) -> Int {
		struct Solution {
			let currentNumber: Int
			let visitedNumbers: [Int]
			let numberOfSteps: Int
		}

		var solutionQueue: Deque<Solution> = [
			.init(currentNumber: 0, visitedNumbers: [0], numberOfSteps: 0),
		]

		var bestSolution: Solution?

		while let solution = solutionQueue.popFirst() {
			if solution.visitedNumbers.count == numbers.count + (returnToStart ? 1 : 0) {
				if let currentBestSolution = bestSolution {
					if solution.numberOfSteps < currentBestSolution.numberOfSteps {
						bestSolution = solution
					}
				} else {
					bestSolution = solution
				}

				continue
			}

			var availableNumbers = numbers.filter { solution.visitedNumbers.contains($0) == false }

			if returnToStart, availableNumbers.isEmpty {
				availableNumbers.append(0)
			}

			for number in availableNumbers {
				let steps = paths[.init(a: solution.currentNumber, b: number)]!

				if let bestSolution, (solution.numberOfSteps + steps) >= bestSolution.numberOfSteps {
					continue
				}

				solutionQueue.append(
					.init(
						currentNumber: number,
						visitedNumbers: solution.visitedNumbers + [number],
						numberOfSteps: solution.numberOfSteps + steps
					)
				)
			}
		}

		return bestSolution!.numberOfSteps
	}

	func solvePart1() -> Any {
		let grid = input.grid

		allNumbers = grid.compactMap { _, value in
			if case .position(let number) = value {
				return number
			} else {
				return nil
			}
		}

		allPaths = allPaths(for: allNumbers, in: grid)

		return minimumNumberOfRequiredSteps(startingAt: 0, with: allNumbers, paths: allPaths)
	}

	func solvePart2() -> Any {
		minimumNumberOfRequiredSteps(startingAt: 0, with: allNumbers, paths: allPaths, returnToStart: true)
	}

	func parseInput(rawString: String) {
		var grid: [Point2D: Node] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, field) in line.enumerated() {
				let node: Node

				switch field {
				case "#":
					node = .wall
				case ".":
					node = .free
				default:
					node = .position(number: Int(String(field))!)
				}

				grid[.init(x: x, y: y)] = node
			}
		}

		input = .init(grid: grid)
	}
}
