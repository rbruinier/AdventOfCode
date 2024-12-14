import Foundation
import Tools

final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	struct Input {
		let fields: [Field]

		let yourTicket: [Int]

		let nearbyTickets: [[Int]]
	}

	private struct Field {
		let name: String
		let ranges: [ClosedRange<Int>]

		func matches(value: Int) -> Bool {
			ranges.contains { $0.contains(value) }
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var invalidValuesSum = 0

		for nearbyTicket in input.nearbyTickets {
			for value in nearbyTicket {
				if input.fields.contains(where: { $0.matches(value: value) }) == false {
					invalidValuesSum += value
				}
			}
		}

		return invalidValuesSum
	}

	func solvePart2(withInput input: Input) -> Int {
		// get valid tickets
		let validTickets = input.nearbyTickets.filter {
			for value in $0 {
				if input.fields.contains(where: { $0.matches(value: value) }) == false {
					return false
				}
			}

			return true
		}

		// find field matches for each value (value: [field])
		var fieldMatches: [Int: [Int]] = [:]

		for (valueIndex, yourTicketValue) in input.yourTicket.enumerated() {
			for (fieldIndex, field) in input.fields.enumerated() {
				guard field.matches(value: yourTicketValue) else {
					continue
				}

				var fieldIsMatch = true

				for validTicket in validTickets {
					let value = validTicket[valueIndex]

					if field.matches(value: value) == false {
						fieldIsMatch = false

						break
					}
				}

				if fieldIsMatch {
					fieldMatches[valueIndex] = fieldMatches[valueIndex, default: []] + [fieldIndex]
				}
			}
		}

		// now we are going to remove one by one ending up with a single field per value
		var removedFields: [Int] = []
		while true {
			guard
				let uniqueField = fieldMatches.first(where: { _, fields in
					fields.count == 1 && removedFields.contains(fields[0]) == false
				})?.value[0]
			else {
				break
			}

			removedFields.append(uniqueField)

			fieldMatches = fieldMatches.mapValues { fields in
				if fields.count == 1 {
					return fields
				}

				return fields.filter { $0 != uniqueField }
			}
		}

		var result = 1
		for (valueIndex, yourTicketValue) in input.yourTicket.enumerated() {
			let field = fieldMatches[valueIndex]![0]

			if input.fields[field].name.starts(with: "departure") {
				result *= yourTicketValue
			}
		}

		return result
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines(includeEmpty: true)

		var currentlyParsing = 0

		var fields: [Field] = []
		var yourTicket: [Int] = []
		var nearbyTickets: [[Int]] = []

		for line in lines {
			if line.isEmpty {
				currentlyParsing += 1

				continue
			}

			if currentlyParsing == 0 {
				let components = line.components(separatedBy: ": ")

				let fieldName = components[0]
				let ranges: [ClosedRange<Int>] = components[1].components(separatedBy: " or ").map {
					let values = $0.components(separatedBy: "-")

					return Int(values[0])! ... Int(values[1])!
				}

				fields.append(.init(name: fieldName, ranges: ranges))
			} else if currentlyParsing == 1 {
				if line == "nearby tickets:" {
					continue
				}

				yourTicket = line.parseCommaSeparatedInts()
			} else {
				if line == "nearby tickets:" {
					continue
				}

				nearbyTickets.append(line.parseCommaSeparatedInts())
			}
		}

		return .init(fields: fields, yourTicket: yourTicket, nearbyTickets: nearbyTickets)
	}
}
