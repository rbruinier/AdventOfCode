import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	struct Input {
		let games: [Game]
	}

	enum Hand {
		case rock
		case paper
		case scissors

		var score: Int {
			switch self {
			case .rock: 1
			case .paper: 2
			case .scissors: 3
			}
		}

		var beats: Hand {
			switch self {
			case .rock: .scissors
			case .paper: .rock
			case .scissors: .paper
			}
		}

		var draws: Hand {
			self
		}

		var losesFrom: Hand {
			switch self {
			case .rock: .paper
			case .paper: .scissors
			case .scissors: .rock
			}
		}
	}

	struct Game {
		let a: Hand
		let b: Hand
	}

	init() {}

	func solvePart1(withInput input: Input) -> Int {
		var score = 0
		for game in input.games {
			score += game.b.score

			if game.b.beats == game.a {
				score += 6
			} else if game.b.losesFrom == game.a {
				score += 0
			} else {
				score += 3
			}
		}

		return score
	}

	func solvePart2(withInput input: Input) -> Int {
		var score = 0

		for game in input.games {
			switch game.b {
			case .rock: // loose
				score += game.a.beats.score
			case .paper: // draws
				score += game.a.draws.score + 3
			case .scissors: // wins
				score += game.a.losesFrom.score + 6
			}
		}

		return score
	}

	func parseInput(rawString: String) -> Input {
		.init(games: rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			let a: Hand
			let b: Hand

			switch components[0] {
			case "A": a = .rock
			case "B": a = .paper
			case "C": a = .scissors
			default: fatalError()
			}

			switch components[1] {
			case "X": b = .rock
			case "Y": b = .paper
			case "Z": b = .scissors
			default: fatalError()
			}

			return Game(a: a, b: b)
		})
	}
}
