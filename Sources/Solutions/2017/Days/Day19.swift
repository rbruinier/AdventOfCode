import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	struct Input {
		var tiles: [Point2D: String] = [:]
	}

	private func walkPath(tiles: [Point2D: String]) -> (encounteredLetters: String, steps: Int) {
		let tiles = input.tiles

		var currentDirection = Direction.south
		var currentPoint = tiles.keys.filter { $0.y == 0 }.first!

		var encounteredLetters = ""
		var steps = 0

		while let tile = tiles[currentPoint] {
			switch tile {
			case "|",
			     "-":
				break
			case "+":
				switch currentDirection {
				case .north,
				     .south:
					if tiles[currentPoint.moved(to: .west)] != nil {
						currentDirection = .west
					} else if tiles[currentPoint.moved(to: .east)] != nil {
						currentDirection = .east
					} else {
						fatalError()
					}
				case .west,
				     .east:
					if tiles[currentPoint.moved(to: .north)] != nil {
						currentDirection = .north
					} else if tiles[currentPoint.moved(to: .south)] != nil {
						currentDirection = .south
					} else {
						fatalError()
					}
				default: fatalError()
				}
			default:
				if (AsciiCharacter.A ... AsciiCharacter.Z).contains(tile.first!.asciiValue!) {
					encounteredLetters += tile
				} else {
					fatalError()
				}
			}

			currentPoint = currentPoint.moved(to: currentDirection)
			steps += 1
		}

		return (encounteredLetters: encounteredLetters, steps: steps)
	}

	func solvePart1(withInput input: Input) -> String {
		walkPath(tiles: input.tiles).encounteredLetters
	}

	func solvePart2(withInput input: Input) -> Int {
		walkPath(tiles: input.tiles).steps
	}

	func parseInput(rawString: String) -> Input {
		var tiles: [Point2D: String] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, char) in line.enumerated() where char != " " {
				tiles[.init(x: x, y: y)] = String(char)
			}
		}

		return .init(tiles: tiles)
	}
}
