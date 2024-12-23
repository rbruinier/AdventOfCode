import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	struct Input {
		let jumps: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		var jumps = input.jumps

		var steps = 0
		var ip = 0
		while true {
			let jump = jumps[ip]

			jumps[ip] += 1

			ip += jump
			steps += 1

			if (0 ..< jumps.count).contains(ip) == false {
				break
			}
		}

		return steps
	}

	func solvePart2(withInput input: Input) -> Int {
		var jumps = input.jumps

		var steps = 0
		var ip = 0
		while true {
			let jump = jumps[ip]

			if jump < 3 {
				jumps[ip] += 1
			} else {
				jumps[ip] -= 1
			}

			ip += jump
			steps += 1

			if (0 ..< jumps.count).contains(ip) == false {
				break
			}
		}

		return steps
	}

	func parseInput(rawString: String) -> Input {
		return .init(jumps: rawString.allLines().map { Int($0)! })
	}
}
