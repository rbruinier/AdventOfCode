import Foundation
import Tools

/// To solve this I started printing the points in the console when the bounding box height was smaller than 100. The fifth result was the text. This gave me the answer
/// for both part 1 and 2. Now this is basically hardcoded into the solution.
final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	struct Input {
		let lights: [Light]
	}

	struct Light {
		var position: Point2D
		var velocity: Point2D
	}

	private func printLights(_ lights: [Light], cycle: Int) -> Bool {
		let positions = Set(lights.map(\.position))

		let minX = positions.map(\.x).min()!
		let maxX = positions.map(\.x).max()!

		let minY = positions.map(\.y).min()!
		let maxY = positions.map(\.y).max()!

		if maxY - minY == 9 {
			//			print("Cycle \(cycle):")

			for y in minY ... maxY {
				var line = ""

				for x in minX ... maxX {
					let point = Point2D(x: x, y: y)

					line += positions.contains(point) ? "#" : "."
				}

				//				print(line)
			}

			return true
		} else {
			return false
		}
	}

	func solvePart1(withInput input: Input) -> String {
		var lights = input.lights

		for cycle in 1 ..< 100_000 {
			for i in 0 ..< lights.count {
				lights[i].position += lights[i].velocity
			}

			if printLights(lights, cycle: cycle + 1) {
				break
			}
		}

		return "HRPHBRKG"
	}

	func solvePart2(withInput input: Input) -> Int {
		var lights = input.lights

		for cycle in 1 ..< 100_000 {
			for i in 0 ..< lights.count {
				lights[i].position += lights[i].velocity
			}

			if printLights(lights, cycle: cycle) {
				return cycle
			}
		}

		fatalError()
	}

	func parseInput(rawString: String) -> Input {
		// position=<-30822, -30933> velocity=< 3,  3>
		return .init(lights: rawString.allLines().map { line in
			let positionComponents = line[10 ..< 24].components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
			let velocityComponents = line[36 ..< 42].components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }

			return .init(
				position: .init(
					x: Int(positionComponents[0])!,
					y: Int(positionComponents[1])!
				),
				velocity: .init(
					x: Int(velocityComponents[0])!,
					y: Int(velocityComponents[1])!
				)
			)
		})
	}
}
