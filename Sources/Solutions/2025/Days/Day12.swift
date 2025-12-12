import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	private var input: Input!

	struct Shape {
		let rows: [[Bool]]

		let nrOfTaken: Int

		init(rows: [[Bool]]) {
			self.rows = rows

			nrOfTaken = rows.flatMap { $0 }.map { $0 ? 1 : 0 }.reduce(0, +)
		}
	}

	struct Section {
		let size: Size
		let shapes: [Int]
	}

	struct Input {
		let shapes: [Shape]
		let sections: [Section]
	}

	func solvePart1(withInput input: Input) -> Int {
		var count = 0
		for section in input.sections {
			let totalSize = section.size.width * section.size.height

			var totalShapesSize = 0

			for (shapeIndex, shapeCount) in section.shapes.enumerated() {
				totalShapesSize += shapeCount * input.shapes[shapeIndex].nrOfTaken
			}

			let canFit = totalShapesSize <= totalSize

			count += canFit ? 1 : 0
		}

		return count
	}

	func solvePart2(withInput input: Input) -> Int {
		0
	}

	func parseInput(rawString: String) -> Input {
		let allLines = rawString.allLines(includeEmpty: true)

		var shapes: [Shape] = []

		for shapeIndex in 0 ..< 6 {
			let startIndex = 1 + (shapeIndex * 5)

			let shapeLines = Array(allLines[startIndex ..< startIndex + 3])

			var rows: [[Bool]] = .init(repeating: .init(repeating: false, count: 3), count: 3)

			for row in 0 ..< 3 {
				for col in 0 ..< 3 {
					rows[row][col] = shapeLines[row][col] == "#"
				}
			}

			shapes.append(Shape(rows: rows))
		}

		let sectionLines = allLines[30 ..< allLines.count - 1]

		let sections = sectionLines.map { line in
			let components = line.components(separatedBy: ": ")

			let sizeComponents = components[0].components(separatedBy: "x")

			let size = Size(width: Int(sizeComponents[0])!, height: Int(sizeComponents[1])!)

			let shapes = components[1].components(separatedBy: " ").map {
				Int($0)!
			}

			return Section(size: size, shapes: shapes)
		}

		return .init(shapes: shapes, sections: sections)
	}
}
