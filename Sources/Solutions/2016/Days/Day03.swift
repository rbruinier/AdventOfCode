import Foundation
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	struct Input {
		let triangles: [Triangle]
	}

	struct Triangle {
		let a: Int
		let b: Int
		let c: Int

		var isValid: Bool {
			(a + b > c) && (a + c > b) && (b + c > a)
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		input.triangles.filter(\.isValid).count
	}

	func solvePart2(withInput input: Input) -> Int {
		let triangles = input.triangles
		var newTriangles: [Triangle] = []

		var index = 0
		while index < triangles.count {
			newTriangles.append(.init(a: triangles[index].a, b: triangles[index + 1].a, c: triangles[index + 2].a))
			newTriangles.append(.init(a: triangles[index].b, b: triangles[index + 1].b, c: triangles[index + 2].b))
			newTriangles.append(.init(a: triangles[index].c, b: triangles[index + 1].c, c: triangles[index + 2].c))

			index += 3
		}

		return newTriangles.filter(\.isValid).count
	}

	func parseInput(rawString: String) -> Input {
		let triangles: [Triangle] = rawString.allLines().map { line in
			let values = line.getCapturedValues(pattern: "[ ]*([0-9]*)[ ]*([0-9]*)[ ]*([0-9]*)")!

			return .init(a: Int(values[0])!, b: Int(values[1])!, c: Int(values[2])!)
		}

		return .init(triangles: triangles)
	}
}
