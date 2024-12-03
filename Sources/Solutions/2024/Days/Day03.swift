import Foundation
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	let expectedPart1Result = 190604937
	let expectedPart2Result = 82857512

	private var input: Input!

	private struct Input {
		let memory: String
	}

	/// Probably should have used regex but I wasn't sure what to expect in part 2
	private func solve(memory: String, allowEnabling: Bool) -> Int {
		enum Instruction {
			case mul
			case `do`
			case dont
		}
		
		enum ParsingState {
			case none
			case m
			case u
			case l
			case open(instruction: Instruction)
			case operandA(number: Int)
			case comma(operandA: Int)
			case operandB(number: Int, operandA: Int)
			case d
			case o
			case n
			case apostrophe
			case t
		}

		var currentParsingState = ParsingState.none

		var muls: [(a: Int, b: Int)] = []
		var enabled = true

		for character in input.memory {
			switch currentParsingState {
			case .none:
				if character == "m" {
					currentParsingState = .m
				} else if character == "d" {
					currentParsingState = .d
				}
			case .m:
				currentParsingState = character == "u" ? .u : .none
			case .u:
				currentParsingState = character == "l" ? .l : .none
			case .l:
				currentParsingState = character == "(" ? .open(instruction: .mul) : .none
			case .open(let instruction):
				switch instruction {
				case .mul:
					if let digit = Int(String(character)) {
						currentParsingState = .operandA(number: digit)
					} else {
						currentParsingState = .none
					}
				case .do:
					if character == ")" {
						enabled = true
					}

					currentParsingState = .none
				case .dont:
					if character == ")", allowEnabling {
						enabled = false
					}

					currentParsingState = .none
				}
			case .operandA(let existingNumber):
				if let digit = Int(String(character)) {
					let newNumber = existingNumber * 10 + digit

					currentParsingState = newNumber < 1000 ? .operandA(number: newNumber) : .none
				} else {
					currentParsingState = character == "," ? .comma(operandA: existingNumber) : .none
				}
			case .comma(let operandA):
				if let digit = Int(String(character)) {
					currentParsingState = .operandB(number: digit, operandA: operandA)
				} else {
					currentParsingState = .none
				}
			case .operandB(let existingNumber, let operandA):
				if let digit = Int(String(character)) {
					let newNumber = existingNumber * 10 + digit

					currentParsingState = newNumber < 1000 ? .operandB(number: newNumber, operandA: operandA) : .none
				} else {
					if character == ")", enabled {
						muls.append((a: operandA, b: existingNumber))
					}

					currentParsingState = .none
				}
			case .d:
				currentParsingState = character == "o" ? .o : .none
			case .o:
				if character == "(" {
					currentParsingState = .open(instruction: .do)
				} else if character == "n" {
					currentParsingState = .n
				} else {
					currentParsingState = .none
				}
			case .n:
				currentParsingState = character == "'" ? .apostrophe : .none
			case .apostrophe:
				currentParsingState = character == "t" ? .t : .none
			case .t:
				currentParsingState = character == "(" ? .open(instruction: .dont) : .none
			}
		}

		return muls.map { $0.a * $0.b }.reduce(0, +)
	}

	func solvePart1() -> Int {
		solve(memory: input.memory, allowEnabling: false)
	}

	func solvePart2() -> Int {
		solve(memory: input.memory, allowEnabling: true)
	}

	func parseInput(rawString: String) {
		input = .init(memory: rawString.trimmingCharacters(in: .whitespacesAndNewlines))
	}
}
