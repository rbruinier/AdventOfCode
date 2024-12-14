import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	struct Input {
		let games: [Game]
	}

	struct Game {
		struct Set {
			let red: Int
			let green: Int
			let blue: Int
		}

		let id: Int
		let sets: [Set]

		func isValid(withMaxRed maxRed: Int, maxGreen: Int, maxBlue: Int) -> Bool {
			!sets.contains { set in
				set.red > maxRed || set.green > maxGreen || set.blue > maxBlue
			}
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		let maxRed = 12
		let maxGreen = 13
		let maxBlue = 14

		return input.games
			.filter { $0.isValid(withMaxRed: maxRed, maxGreen: maxGreen, maxBlue: maxBlue) }
			.reduce(0) { $0 + $1.id }
	}

	func solvePart2(withInput input: Input) -> Int {
		input.games.reduce(0) { result, game in
			let maxRed = game.sets.map(\.red).max()!
			let maxGreen = game.sets.map(\.green).max()!
			let maxBlue = game.sets.map(\.blue).max()!

			return result + maxRed * maxGreen * maxBlue
		}
	}

	func parseInput(rawString: String) -> Input {
		var gameID = 1

		let games: [Game] = rawString.allLines().map { line in
			defer {
				gameID += 1
			}

			let rawSets = line
				.components(separatedBy: ": ")[1]
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.components(separatedBy: ";")

			let sets: [Game.Set] = rawSets.map { rawSet in
				let rawCubes = rawSet.components(separatedBy: ", ")

				var red = 0
				var green = 0
				var blue = 0

				for rawCube in rawCubes {
					let components = rawCube
						.trimmingCharacters(in: .whitespacesAndNewlines)
						.components(separatedBy: " ")

					switch components[1] {
					case "red": red += Int(components[0])!
					case "green": green += Int(components[0])!
					case "blue": blue += Int(components[0])!
					default: preconditionFailure()
					}
				}

				return .init(red: red, green: green, blue: blue)
			}

			return .init(id: gameID, sets: sets)
		}

		return .init(games: games)
	}
}
