import Foundation
import Tools

final class Day11Solver: DaySolver {
	let dayNumber: Int = 11

	private var input: Input!

	private struct Input {
		let monkeys: [Monkey]
	}

	private struct Monkey {
		struct Test {
			var divisor: Int
			var ifTrueMonkeyIndex: Int
			var ifFalseMonkeyIndex: Int
		}

		enum Operation {
			case add(value: Int?)
			case mul(value: Int?)
		}

		var items: [Int]
		var operation: Operation
		var test: Test
	}

	init() {}

	func solvePart1() -> Int {
		var monkeys = input.monkeys

		var inspectionCounter: [Int: Int] = [:]

		let rounds = 20
		for _ in 0 ..< rounds {
			for index in 0 ..< monkeys.count {
				var monkey = monkeys[index]

				for item in monkey.items {
					inspectionCounter[index, default: 0] += 1

					var worryLevel = item

					switch monkey.operation {
					case .add(let value):
						worryLevel += value ?? worryLevel
					case .mul(let value):
						worryLevel *= value ?? worryLevel
					}

					worryLevel /= 3

					if (worryLevel % monkey.test.divisor) == 0 {
						monkeys[monkey.test.ifTrueMonkeyIndex].items.append(worryLevel)
					} else {
						monkeys[monkey.test.ifFalseMonkeyIndex].items.append(worryLevel)
					}
				}

				monkey.items.removeAll()

				monkeys[index] = monkey
			}
		}

		return inspectionCounter.values.sorted().suffix(2).reduce(1, *)
	}

	func solvePart2() -> Int {
		var monkeys = input.monkeys

		var inspectionCounter: [Int: Int] = [:]

		// luckily already encounted LCM in previous puzzles
		// see: https://en.wikipedia.org/wiki/Chinese_remainder_theorem
		//
		// we basically find the boundary of the number space where the logic would be identical (but with higher numbers)
		// we can modulo all levels with this so we maintain the worry levels in this space
		let commonDivisor = Math.leastCommonMultiple(for: monkeys.map(\.test.divisor))

		let rounds = 10_000
		for _ in 0 ..< rounds {
			for index in 0 ..< monkeys.count {
				var monkey = monkeys[index]

				for item in monkey.items {
					inspectionCounter[index, default: 0] += 1

					var worryLevel = item

					switch monkey.operation {
					case .add(let value):
						worryLevel += value ?? worryLevel
					case .mul(let value):
						worryLevel *= value ?? worryLevel
					}

					worryLevel %= commonDivisor

					if (worryLevel % monkey.test.divisor) == 0 {
						monkeys[monkey.test.ifTrueMonkeyIndex].items.append(worryLevel)
					} else {
						monkeys[monkey.test.ifFalseMonkeyIndex].items.append(worryLevel)
					}
				}

				monkey.items.removeAll()

				monkeys[index] = monkey
			}
		}

		return inspectionCounter.values.sorted().suffix(2).reduce(1, *)
	}

	func parseInput(rawString: String) {
		var monkeys: [Monkey] = []

		let lines = rawString.allLines(includeEmpty: false)

		let numberOfMonkeys = lines.count / 6

		for index in 0 ..< numberOfMonkeys {
			let monkeyLines = Array(lines[(index * 6) ..< ((index + 1) * 6)])

			let startingItems = monkeyLines[1].components(separatedBy: ": ")[1].components(separatedBy: ", ").map { Int($0)! }
			let operand = monkeyLines[2].components(separatedBy: " ")[7]

			let operation: Monkey.Operation

			switch monkeyLines[2].components(separatedBy: " ")[6] {
			case "+": operation = .add(value: Int(operand))
			case "*": operation = .mul(value: Int(operand))
			default: fatalError()
			}

			let test = Monkey.Test(
				divisor: Int(monkeyLines[3].components(separatedBy: " ")[5])!,
				ifTrueMonkeyIndex: Int(monkeyLines[4].components(separatedBy: " ")[9])!,
				ifFalseMonkeyIndex: Int(monkeyLines[5].components(separatedBy: " ")[9])!
			)

			monkeys.append(.init(items: startingItems, operation: operation, test: test))
		}

		input = .init(monkeys: monkeys)
	}
}
