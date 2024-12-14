import Foundation
import RegexBuilder
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	struct Machine {
		let a: Point2D
		let b: Point2D
		let prize: Point2D
	}

	struct Input {
		let machines: [Machine]
	}

	private func tokensForMachine(_ machine: Machine) -> Int? {
		// From wikipedia:
		// This Diophantine equation has a solution (where x and y are integers) if and only if c is a multiple of the greatest common divisor of a and b.
		// Moreover, if (x, y) is a solution, then the other solutions have the form (x + kv, y − ku), where k is an arbitrary integer, and u and v are the
		// quotients of a and b (respectively) by the greatest common divisor of a and b.

		var ap = machine.prize.x
		var ax = machine.a.x
		var ay = machine.b.x

		var bp = machine.prize.y
		var bx = machine.a.y
		var by = machine.b.y

		let aCommonDivisor = Math.greatestCommonFactor(ax, ay)
		let bCommonDivisor = Math.greatestCommonFactor(bx, by)

		// check if there is a solution
		guard ap % aCommonDivisor == 0, bp % bCommonDivisor == 0 else {
			return nil
		}

		let ty = ay

		// eliminate b by equalizing them
		ap *= by
		ax *= by
		ay *= by

		bp *= ty
		bx *= ty
		by *= ty

		// subtract equation 2 from 1
		ap -= bp
		ax -= bx
		ay -= by

		// now we can calculate x
		if ap % ax != 0 {
			return nil
		}

		let x = ap / ax

		// we plug x in the original equation and solve y
		if (machine.prize.x - (x * machine.a.x)) % machine.b.x != 0 {
			return nil
		}

		let y = (machine.prize.x - (x * machine.a.x)) / machine.b.x

		guard x >= 0, y >= 0 else {
			return nil
		}

		return x * 3 + y
	}

	func solvePart1(withInput input: Input) -> Int {
		input.machines.compactMap(tokensForMachine(_:)).reduce(0, +)
	}

	func solvePart2(withInput input: Input) -> Int {
		let newMachines: [Machine] = input.machines.map { .init(
			a: $0.a, b: $0.b, prize: .init(x: $0.prize.x + 10_000_000_000_000, y: $0.prize.y + 10_000_000_000_000)
		) }

		return newMachines.compactMap(tokensForMachine(_:)).reduce(0, +)
	}

	func parseInput(rawString: String) -> Input {
		var machines: [Machine] = []

		let allLines = rawString.allLines()
		for machineIndex in stride(from: 0, to: allLines.count, by: 3) {
			let lineA = allLines[machineIndex]
			let lineB = allLines[machineIndex + 1]
			let linePrize = allLines[machineIndex + 2]

			let buttonRegex = Regex {
				"Button "
				OneOrMore(.word, .possessive)
				": X+"
				Capture {
					OneOrMore(.digit)
				} transform: { Int($0)! }
				", Y+"
				Capture {
					OneOrMore(.digit)
				} transform: { Int($0)! }
			}

			let prizeRegex = Regex {
				"Prize: X="
				Capture {
					OneOrMore(.digit)
				} transform: { Int($0)! }
				", Y="
				Capture {
					OneOrMore(.digit)
				} transform: { Int($0)! }
			}

			guard
				let buttonAMatch = try? buttonRegex.firstMatch(in: lineA),
				let buttonBMatch = try? buttonRegex.firstMatch(in: lineB),
				let prizeMatch = try? prizeRegex.firstMatch(in: linePrize)
			else {
				preconditionFailure()
			}

			machines.append(.init(
				a: .init(x: buttonAMatch.output.1, y: buttonAMatch.output.2),
				b: .init(x: buttonBMatch.output.1, y: buttonBMatch.output.2),
				prize: .init(x: prizeMatch.output.1, y: prizeMatch.output.2)
			))
		}

		return .init(machines: machines)
	}
}
