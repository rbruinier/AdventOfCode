import Foundation
import Tools

/// First I tried to solve part 2 by brute forcing a million values for humn (x from now on) but that did not work. Using the debugger I looked at which part changes when x changes
/// and figured out the B operand of the root equate is constant. Then I printed out the A operand equation and replaced humn value with "x". After that I used https://quickmath.com/
/// to solve the equation RHS VALUE = LHS EQUATION and this website then gives you the value for X.
///
/// I guess we could also collapse most of the equation and then do this by hand or even brute force, not sure about that.
final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	private var input: Input!

	private struct Input {
		let monkeys: [String: Operation]
	}

	private enum Operation {
		case value(Int)
		case add(a: String, b: String)
		case sub(a: String, b: String)
		case mul(a: String, b: String)
		case div(a: String, b: String)
		case equate(a: String, b: String)

		var operands: (a: String, b: String)? {
			switch self {
			case .value:
				nil
			case .add(let a, let b):
				(a: a, b: b)
			case .sub(let a, let b):
				(a: a, b: b)
			case .mul(let a, let b):
				(a: a, b: b)
			case .div(let a, let b):
				(a: a, b: b)
			case .equate(let a, let b):
				(a: a, b: b)
			}
		}
	}

	init() {}

	private func solvePart1ForID(_ id: String, monkeys: [String: Operation]) -> Int {
		guard let operation = monkeys[id] else {
			fatalError()
		}

		switch operation {
		case .value(let value):
			return value
		case .add(let a, let b):
			return solvePart1ForID(a, monkeys: monkeys) + solvePart1ForID(b, monkeys: monkeys)
		case .sub(let a, let b):
			return solvePart1ForID(a, monkeys: monkeys) - solvePart1ForID(b, monkeys: monkeys)
		case .mul(let a, let b):
			return solvePart1ForID(a, monkeys: monkeys) * solvePart1ForID(b, monkeys: monkeys)
		case .div(let a, let b):
			return solvePart1ForID(a, monkeys: monkeys) / solvePart1ForID(b, monkeys: monkeys)
		case .equate:
			fatalError("Not supported in part 1")
		}
	}

	private func solvePart2ForID(_ id: String, monkeys: [String: Operation]) -> Int {
		guard let operation = monkeys[id] else {
			fatalError()
		}

		switch operation {
		case .value(let value):
			return value
		case .add(let a, let b):
			return solvePart2ForID(a, monkeys: monkeys) + solvePart2ForID(b, monkeys: monkeys)
		case .sub(let a, let b):
			return solvePart2ForID(a, monkeys: monkeys) - solvePart2ForID(b, monkeys: monkeys)
		case .mul(let a, let b):
			return solvePart2ForID(a, monkeys: monkeys) * solvePart2ForID(b, monkeys: monkeys)
		case .div(let a, let b):
			return solvePart2ForID(a, monkeys: monkeys) / solvePart2ForID(b, monkeys: monkeys)
		case .equate(let a, let b):
			let lhs = solvePart2ForID(a, monkeys: monkeys)
			let rhs = solvePart2ForID(b, monkeys: monkeys)

			return lhs == rhs ? 1 : 0
		}
	}

	private func equationStringForID(_ id: String, monkeys: [String: Operation]) -> String {
		guard let operation = monkeys[id] else {
			fatalError()
		}

		switch operation {
		case .value(let value):
			return String(value)
		case .add(let a, let b):
			let lhs = a == "humn" ? "x" : equationStringForID(a, monkeys: monkeys)
			let rhs = b == "humn" ? "x" : equationStringForID(b, monkeys: monkeys)

			return "(\(lhs) + \(rhs))"
		case .sub(let a, let b):
			let lhs = a == "humn" ? "x" : equationStringForID(a, monkeys: monkeys)
			let rhs = b == "humn" ? "x" : equationStringForID(b, monkeys: monkeys)

			return "(\(lhs) - \(rhs))"
		case .mul(let a, let b):
			let lhs = a == "humn" ? "x" : equationStringForID(a, monkeys: monkeys)
			let rhs = b == "humn" ? "x" : equationStringForID(b, monkeys: monkeys)

			return "(\(lhs) * \(rhs))"
		case .div(let a, let b):
			let lhs = a == "humn" ? "x" : equationStringForID(a, monkeys: monkeys)
			let rhs = b == "humn" ? "x" : equationStringForID(b, monkeys: monkeys)

			return "(\(lhs) / \(rhs))"
		case .equate:
			fatalError("Do not use on root")
		}
	}

	func solvePart1() -> Int {
		solvePart1ForID("root", monkeys: input.monkeys)
	}

	func solvePart2() -> Int {
		var monkeys = input.monkeys

		let rootOperands = monkeys["root"]!.operands!

		let humnValue = 3782852515583
		//		let rhsResult = 99433652936583 // found by setting a break point @ line 86

		monkeys["root"] = .equate(a: rootOperands.a, b: rootOperands.b)
		monkeys["humn"] = .value(humnValue)

		let result = solvePart2ForID("root", monkeys: monkeys)

		guard result == 1 else {
			fatalError()
		}

		return humnValue
	}

	func parseInput(rawString: String) {
		var monkeys: [String: Operation] = [:]

		for line in rawString.allLines() {
			let components = line.components(separatedBy: ": ")

			let id = components[0]
			let operation: Operation

			if let value = Int(components[1]) {
				operation = .value(value)
			} else if let values = components[1].getCapturedValues(pattern: #"([a-z]*) \+ ([a-z]*)"#) {
				operation = .add(a: values[0], b: values[1])
			} else if let values = components[1].getCapturedValues(pattern: #"([a-z]*) \- ([a-z]*)"#) {
				operation = .sub(a: values[0], b: values[1])
			} else if let values = components[1].getCapturedValues(pattern: #"([a-z]*) \* ([a-z]*)"#) {
				operation = .mul(a: values[0], b: values[1])
			} else if let values = components[1].getCapturedValues(pattern: #"([a-z]*) \/ ([a-z]*)"#) {
				operation = .div(a: values[0], b: values[1])
			} else {
				fatalError()
			}

			monkeys[id] = operation
		}

		input = .init(monkeys: monkeys)
	}
}
