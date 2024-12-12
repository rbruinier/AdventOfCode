import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	private var input: Input!

	private struct Input {
		let boxes: [Point3D]
	}

	func solvePart1() -> Int {
		var total = 0

		for box in input.boxes {
			let side1 = box.x * box.y
			let side2 = box.y * box.z
			let side3 = box.x * box.z

			let surfaceArea = (2 * side1) + (2 * side2) + (2 * side3)

			total += surfaceArea + min(min(side1, side2), side3)
		}

		return total
	}

	func solvePart2() -> Int {
		var total = 0

		for box in input.boxes {
			let ordered: [Int] = [box.x, box.y, box.z].sorted()

			let ribbon = (2 * ordered[0]) + (2 * ordered[1])
			let bow = box.x * box.y * box.z

			total += ribbon + bow
		}

		return total
	}

	func parseInput(rawString: String) {
		let boxes: [Point3D] = rawString.allLines().map { line in
			let components = line.components(separatedBy: "x")

			return .init(x: Int(components[0])!, y: Int(components[1])!, z: Int(components[2])!)
		}

		input = .init(boxes: boxes)
	}
}
