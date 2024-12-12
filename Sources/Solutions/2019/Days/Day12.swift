import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	private var input: Input!

	private struct Input {
		let moons: [Moon]
	}

	private struct Moon: Equatable, Hashable {
		var position: Point3D
		var velocity: Point3D = .init()

		var potentialEnergy: Int {
			abs(position.x) + abs(position.y) + abs(position.z)
		}

		var kineticEnergy: Int {
			abs(velocity.x) + abs(velocity.y) + abs(velocity.z)
		}

		var energy: Int {
			potentialEnergy * kineticEnergy
		}
	}

	private func updateMoons(moons: [Moon]) -> [Moon] {
		var updatedMoons = moons

		for outerMoonIndex in 0 ..< moons.count {
			var velocity = moons[outerMoonIndex].velocity
			var position = moons[outerMoonIndex].position

			for innerMoonIndex in 0 ..< moons.count where outerMoonIndex != innerMoonIndex {
				let delta = moons[innerMoonIndex].position - moons[outerMoonIndex].position

				velocity.x += delta.x.sign
				velocity.y += delta.y.sign
				velocity.z += delta.z.sign
			}

			position += velocity

			updatedMoons[outerMoonIndex] = .init(position: position, velocity: velocity)
		}

		return updatedMoons
	}

	func solvePart1() -> Int {
		var moons = input.moons

		for _ in 0 ..< 1000 {
			moons = updateMoons(moons: moons)
		}

		return moons.map(\.energy).reduce(0, +)
	}

	func solvePart2() -> Int {
		var moons = input.moons

		// the axis do not influence each other so we can focus on individual axis and find the least common multiplier for the 3 counters to see where they align
		var stateXCounter = 0
		var stateYCounter = 0
		var stateZCounter = 0

		let startState = input.moons

		var counter = 0
		firstMatchLoop: while true {
			moons = updateMoons(moons: moons)

			counter += 1

			var allXSameState = true
			var allYSameState = true
			var allZSameState = true

			for moonIndex in 0 ..< moons.count {
				if moons[moonIndex].position.x != startState[moonIndex].position.x || moons[moonIndex].velocity.x != startState[moonIndex].velocity.x {
					allXSameState = false
				}

				if moons[moonIndex].position.y != startState[moonIndex].position.y || moons[moonIndex].velocity.y != startState[moonIndex].velocity.y {
					allYSameState = false
				}

				if moons[moonIndex].position.z != startState[moonIndex].position.z || moons[moonIndex].velocity.z != startState[moonIndex].velocity.z {
					allZSameState = false
				}
			}

			if allXSameState, stateXCounter == 0 {
				stateXCounter = counter
			}

			if allYSameState, stateYCounter == 0 {
				stateYCounter = counter
			}

			if allZSameState, stateZCounter == 0 {
				stateZCounter = counter
			}

			if stateXCounter != 0, stateYCounter != 0, stateZCounter != 0 {
				break
			}
		}

		return Math.leastCommonMultiple(for: [stateXCounter, stateYCounter, stateZCounter])
	}

	func parseInput(rawString: String) {
		let moons: [Moon] = rawString.allLines().map { line in
			let rawCoordinates = line[1 ..< line.count - 1].components(separatedBy: ", ")

			let x = Int(rawCoordinates[0].components(separatedBy: "=")[1])!
			let y = Int(rawCoordinates[1].components(separatedBy: "=")[1])!
			let z = Int(rawCoordinates[2].components(separatedBy: "=")[1])!

			return .init(position: .init(x: x, y: y, z: z))
		}

		input = .init(moons: moons)
	}
}
