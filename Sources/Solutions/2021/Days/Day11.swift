import Foundation
import Tools

final class Day11Solver: DaySolver {
	let dayNumber: Int = 11

	struct Input {
		let octopi: [Octopus]

		let width: Int
		let height: Int
	}

	fileprivate struct Octopus {
		var energyLevel: Int
	}

	private func incrementAt(y: Int, x: Int, width: Int, height: Int, octopi: inout [Octopus]) {
		let level = octopi[(y * width) + x].energyLevel + 1

		if level <= 10 {
			octopi[(y * width) + x].energyLevel = level
		}

		guard level == 10 else {
			return
		}

		for innerY in max(y - 1, 0) ... min(y + 1, height - 1) {
			for innerX in max(x - 1, 0) ... min(x + 1, width - 1) {
				if innerY == y, innerX == x {
					continue
				}

				incrementAt(y: innerY, x: innerX, width: width, height: height, octopi: &octopi)
			}
		}
	}

	struct Key: Hashable {
		let step: Int
		let level: Int
	}

	private func executeStep(octopi: inout [Octopus]) -> Int {
		// phase 1 is incrementing
		for y in 0 ..< input.height {
			for x in 0 ..< input.width {
				incrementAt(y: y, x: x, width: input.width, height: input.height, octopi: &octopi)
			}
		}

		var numberOfFlashes = 0

		// phase 2 is flashing and resetting
		for y in 0 ..< input.height {
			for x in 0 ..< input.width {
				if octopi[(y * input.width) + x].energyLevel >= 10 {
					numberOfFlashes += 1

					octopi[(y * input.width) + x].energyLevel = 0
				}
			}
		}

		return numberOfFlashes
	}

	func solvePart1(withInput input: Input) -> Int {
		var octopi = input.octopi

		var totalNumberOfFlashes = 0

		for _ in 0 ..< 100 {
			totalNumberOfFlashes += executeStep(octopi: &octopi)
		}

		return totalNumberOfFlashes
	}

	func solvePart2(withInput input: Input) -> Int {
		var octopi = input.octopi

		for step in 0 ..< Int.max {
			let numberOfFlashes = executeStep(octopi: &octopi)

			if numberOfFlashes == input.octopi.count {
				return step + 1
			}
		}

		return -1
	}

	func parseInput(rawString: String) -> Input {
		let height = rawString.filter(\.isNewline).count

		let octopi: [Octopus] = rawString
			.compactMap { Int(String($0)) }
			.map(Octopus.init(energyLevel:))

		let width = octopi.count / height

		return .init(octopi: octopi, width: width, height: height)
	}
}

//extension Day11Solver {
//	func createVisualizer() -> Visualizer? {
//		StepsVisualizer(solver: self)
//	}
//
//	/// The solver does not generate useful data for visualization so instead we redo it but with a different, non-recursive, algorithm
//	final class StepsVisualizer: Visualizer {
//		private struct VisualizationState {
//			let step: Int
//			let state: [Octopus]
//			let flashes: Int
//		}
//
//		private var statesToVisualize: [VisualizationState] = []
//		private var flashCounter: [Int] = Array(repeating: 0, count: 100)
//
//		private var squareSize: Size {
//			.init(width: 15, height: 15)
//		}
//
//		var dimensions: Size {
//			.init(width: squareSize.width * 11, height: squareSize.height * 11)
//		}
//
//		var frameDescription: String?
//
//		var isCompleted: Bool = false
//
//		let solver: any DaySolver
//
//		init(solver: Day11Solver) {
//			self.solver = solver
//
//			var currentState = solver.input.octopi
//			var currentStep = 0
//			var flashes = 0
//
//			statesToVisualize.append(.init(step: currentStep, state: currentState, flashes: flashes))
//
//			while currentStep < 100 {
//				var hasFlashed: Set<Int> = []
//
//				for i in 0 ..< currentState.count {
//					currentState[i].energyLevel += 1
//				}
//
//				statesToVisualize.append(.init(step: currentStep, state: currentState, flashes: flashes))
//
//				while true {
//					var index = 0
//					var hasIncrement = false
//
//					for y in 0 ..< 10 {
//						for x in 0 ..< 10 {
//							defer {
//								index += 1
//							}
//
//							guard hasFlashed.contains(index) == false else {
//								continue
//							}
//
//							if currentState[index].energyLevel >= 10 {
//								hasIncrement = true
//
//								flashes += 1
//
//								hasFlashed.insert(index)
//
//								for innerY in max(0, y - 1) ... min(9, y + 1) {
//									for innerX in max(0, x - 1) ... min(9, x + 1) where (y == innerY && x == innerX) == false {
//										currentState[innerY * 10 + innerX].energyLevel += 1
//									}
//								}
//							}
//						}
//					}
//
//					if hasIncrement {
//						statesToVisualize.append(.init(step: currentStep, state: currentState, flashes: flashes))
//					} else {
//						currentStep += 1
//
//						break
//					}
//				}
//
//				for index in 0 ..< currentState.count {
//					currentState[index].energyLevel = currentState[index].energyLevel >= 10 ? 0 : currentState[index].energyLevel
//				}
//			}
//		}
//
//		func renderFrame(with context: VisualizationContext) {
//			context.startNewFrame()
//
//			let stateToVisualize = statesToVisualize[context.frameCounter]
//
//			let squareSize = squareSize
//
//			var index = 0
//			for y in 0 ..< 9 {
//				for x in 0 ..< 9 {
//					let value = stateToVisualize.state[index].energyLevel
//
//					flashCounter[index] = max(flashCounter[index] - 1, 0)
//
//					if value >= 10 {
//						flashCounter[index] = 10
//					}
//
//					let textPoint = Point2D(
//						x: ((x + 1) * squareSize.width) + 5,
//						y: ((y + 1) * squareSize.height) + 4
//					)
//
//					let flash: UInt8
//
//					if flashCounter[index] <= 1 {
//						flash = 0
//					} else {
//						flash = UInt8(flashCounter[index] * 25)
//					}
//
//					let fillColor = Color(r: flash, g: flash, b: flash)
//					let textColor = Color.hotPink
//
//					let rect = Rect(origin: .init(x: (x + 1) * squareSize.width, y: (y + 1) * squareSize.height), size: squareSize)
//
//					context.fillRect(rect, color: fillColor)
//
//					if value >= 10 {
//						context.drawText("0", at: textPoint, color: textColor)
//					} else {
//						context.drawText(String(value), at: textPoint, color: textColor)
//					}
//
//					index += 1
//				}
//			}
//
//			frameDescription = "Step: \(stateToVisualize.step + 1); Flashes: \(stateToVisualize.flashes)"
//
//			if context.frameCounter == statesToVisualize.count - 1 {
//				isCompleted = true
//			}
//		}
//	}
//}
