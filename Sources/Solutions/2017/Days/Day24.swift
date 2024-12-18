import Foundation
import Tools

final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	struct Input {
		let ports: [Port]
	}

	struct Port: Hashable {
		let id: UUID = .init()

		let a: Int
		let b: Int

		let strength: Int

		init(a: Int, b: Int) {
			self.a = a
			self.b = b

			strength = a + b
		}

		static func == (_ lhs: Port, _ rhs: Port) -> Bool {
			lhs.id == rhs.id
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}

	private func bestStrength(withInput input: Int, remainingPorts: Set<Port>) -> Int {
		if remainingPorts.isEmpty {
			return 0
		}

		let availablePorts = remainingPorts.filter {
			$0.a == input || $0.b == input
		}

		var maxStrength = 0

		for availablePort in availablePorts {
			let output: Int

			if availablePort.a == input {
				output = availablePort.b
			} else {
				output = availablePort.a
			}

			var newRemainingPorts = remainingPorts

			newRemainingPorts.remove(availablePort)

			maxStrength = max(
				maxStrength,
				availablePort.strength + bestStrength(
					withInput: output,
					remainingPorts: newRemainingPorts
				)
			)
		}

		return maxStrength
	}

	private func bestLength(withInput input: Int, remainingPorts: Set<Port>) -> (strength: Int, length: Int) {
		if remainingPorts.isEmpty {
			return (strength: 0, length: 0)
		}

		let availablePorts = remainingPorts.filter {
			$0.a == input || $0.b == input
		}

		var maxLength = 0
		var maxStrength = 0

		for availablePort in availablePorts {
			let output: Int

			if availablePort.a == input {
				output = availablePort.b
			} else {
				output = availablePort.a
			}

			var newRemainingPorts = remainingPorts

			newRemainingPorts.remove(availablePort)

			let result = bestLength(
				withInput: output,
				remainingPorts: newRemainingPorts
			)

			let length = 1 + result.length
			let strength = availablePort.strength + result.strength

			if length > maxLength {
				maxLength = length
				maxStrength = strength
			} else if length == maxLength, strength > maxStrength {
				maxStrength = strength
			}
		}

		return (strength: maxStrength, length: maxLength)
	}

	func solvePart1(withInput input: Input) -> Int {
		bestStrength(withInput: 0, remainingPorts: Set(input.ports))
	}

	func solvePart2(withInput input: Input) -> Int {
		bestLength(withInput: 0, remainingPorts: Set(input.ports)).strength
	}

	func parseInput(rawString: String) -> Input {
		return .init(ports: rawString.allLines().map { line in
			let components = line.components(separatedBy: "/")

			return Port(a: Int(components[0])!, b: Int(components[1])!)
		})
	}
}
