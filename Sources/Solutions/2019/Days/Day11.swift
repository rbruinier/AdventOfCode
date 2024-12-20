import Foundation
import Tools

final class Day11Solver: DaySolver {
	let dayNumber: Int = 11

	struct Input {
		let program: [Int]
	}

	private func runProgram(_ program: [Int], startPanels: [Point2D: Int]) -> [Point2D: Int] {
		let intcode = IntcodeProcessor(program: program)

		var position = Point2D()
		var direction = Point2D(x: 0, y: -1)

		var panels: [Point2D: Int] = startPanels

		while true {
			let input = panels[position, default: 0]

			guard
				let color = intcode.continueProgramTillOutput(input: [input]),
				let turn = intcode.continueProgramTillOutput(input: [input])
			else {
				break
			}

			panels[position] = color

			switch turn {
			case 1:
				direction = direction.turned(degrees: .twoSeventy)
			case 0:
				direction = direction.turned(degrees: .ninety)
			default: fatalError()
			}

			position += direction
		}

		return panels
	}

	func solvePart1(withInput input: Input) -> Int {
		runProgram(input.program, startPanels: [:]).keys.count
	}

	func solvePart2(withInput input: Input) -> String {
		let panels = runProgram(input.program, startPanels: [.init(x: 0, y: 0): 1])

		let points = panels.keys

		let minX = points.map(\.x).min()!
		let minY = points.map(\.y).min()!

		let maxX = points.map(\.x).max()!
		let maxY = points.map(\.y).max()!

		for y in minY ... maxY {
			var line = ""

			for x in minX ... maxX {
				if panels[.init(x: x, y: y)] == 1 {
					line += "#"
				} else {
					line += " "
				}
			}

			//            print(line)
		}

		return "KLCZAEGU"
	}

	func parseInput(rawString: String) -> Input {
		return .init(program: rawString.parseCommaSeparatedInts())
	}
}
