import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	struct Input {
		let program: [Int]
	}

	private enum Tile: Int {
		case empty = 0
		case wall = 1
		case block = 2
		case horizontalPaddle = 3
		case ball = 4
	}

	private func printGame(with tiles: [Point2D: Tile]) {
		let minX = tiles.keys.map(\.x).min()!
		let minY = tiles.keys.map(\.y).min()!

		let maxX = tiles.keys.map(\.x).max()!
		let maxY = tiles.keys.map(\.y).max()!

		for y in minY ... maxY {
			var line = ""

			for x in minX ... maxX {
				switch tiles[.init(x: x, y: y)]! {
				case .wall:
					line += "+"
				case .empty:
					line += " "
				case .block:
					line += "#"
				case .horizontalPaddle:
					line += "="
				case .ball:
					line += "*"
				}
			}

			print(line)
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		let intcode = IntcodeProcessor(program: input.program)

		var tiles: [Point2D: Tile] = [:]

		while true {
			guard
				let x = intcode.continueProgramTillOutput(input: []),
				let y = intcode.continueProgramTillOutput(input: []),
				let tileID = intcode.continueProgramTillOutput(input: []),
				let tile = Tile(rawValue: tileID)
			else {
				break
			}

			tiles[.init(x: x, y: y)] = tile
		}

		return tiles.values.filter { $0 == .block }.count
	}

	func solvePart2(withInput input: Input) -> Int {
		var program = input.program

		program[0] = 2 // insert 2 quarters :)

		let intcode = IntcodeProcessor(program: program)

		var tiles: [Point2D: Tile] = [:]

		var ballPosition: Point2D = .init(x: 0, y: 0)
		var paddlePosition: Point2D = .init(x: 0, y: 0)

		// play game
		var score = 0
		while true {
			let input: Int

			if ballPosition.x < paddlePosition.x {
				input = -1
			} else if ballPosition.x > paddlePosition.x {
				input = 1
			} else {
				input = 0
			}

			if let output = intcode.continueProgramTillOutput(input: [input]) {
				if output == -1 {
					_ = intcode.continueProgramTillOutput(input: [])!

					score = intcode.continueProgramTillOutput(input: [])!

					if tiles.values.filter({ $0 == .block }).isEmpty {
						break
					}
				} else {
					let x = output
					let y = intcode.continueProgramTillOutput(input: [])!
					let tileID = intcode.continueProgramTillOutput(input: [])!
					let tile = Tile(rawValue: tileID)!

					tiles[.init(x: x, y: y)] = tile

					if tile == .ball {
						ballPosition = .init(x: x, y: y)
					} else if tile == .horizontalPaddle {
						paddlePosition = .init(x: x, y: y)
					}
				}
			}
		}

		return score
	}

	func parseInput(rawString: String) -> Input {
		.init(program: rawString.parseCommaSeparatedInts())
	}
}
