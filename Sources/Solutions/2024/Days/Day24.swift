import Foundation
import Tools

final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	struct Gate: CustomStringConvertible {
		enum Operation: String, CustomStringConvertible {
			case and = "AND"
			case or = "OR"
			case xor = "XOR"

			var description: String {
				rawValue
			}
		}

		let operation: Operation

		let inputA: String
		let inputB: String

		let output: String

		var didProduceOutput: Bool = false

		var description: String {
			"\(inputA) \(operation) \(inputB) -> \(output)"
		}
	}

	struct Input {
		var wires: [String: Bool]
		var gates: [Gate]
	}

	func solvePart1(withInput input: Input) -> Int {
		var wires = input.wires
		var gates = input.gates

		while gates.contains(where: { $0.didProduceOutput == false }) {
			for (index, gate) in gates.enumerated() {
				guard let a = wires[gate.inputA], let b = wires[gate.inputB] else {
					continue
				}

				let output: Bool

				switch gate.operation {
				case .and: output = a && b
				case .or: output = a || b
				case .xor: output = a != b
				}

				wires[gate.output] = output

				gates[index].didProduceOutput = true
			}
		}

		let zWires = wires.keys.filter { $0.starts(with: "z") }.sorted()

		var binaryDigits = ""
		for zWire in zWires {
			binaryDigits = (wires[zWire]! ? "1" : "0") + binaryDigits
		}

		return Int(binaryDigits, radix: 2)!
	}

	func solvePart2(withInput input: Input) -> String {
		// Idea one: inspect how z00 gets build, z01, z02, to make sure we are looking at correct ones
		// lets reverse print the tree for z00

		// Z00:
		//  -> x00 XOR y00 -> z00 <- correct
		// Z01:
		//  -> y01 XOR x01 -> tdh
		//  -> x00 AND y00 -> gtb <- carried from z00
		//  -> tdh XOR gtb -> z01
		// Z02:
		//  -> gtb AND tdh -> svv <- carried from z01 calculation
		//  -> x01 AND y01 -> vpp
		//  -> svv OR vpp -> prf
		//  -> x02 XOR y02 -> dvr
		//  -> prf XOR dvr -> z02
		// Z03:
		//  -> prf AND dvr -> npq <- z2
		//  -> x02 AND y02 -> qvc
		//  -> npq OR qvc -> ptp
		//  -> y03 XOR x03 -> tcb
		//  -> tcb XOR ptp -> z03

		// from z02 onwards we need
		// 2 adders
		// 1 or
		// 2 xors

		var wires = input.wires
		var gates = input.gates

		func isValidGateFor(digitID: Int) -> Bool {
			let xWire = "x" + String(format: "%02d", digitID)
			let yWire = "y" + String(format: "%02d", digitID)
			let zWire = "z" + String(format: "%02d", digitID)

			let outputGate = gates.first(where: { $0.output == zWire })!

			if outputGate.operation != .xor {
				return false
			}

			let inputGateA = gates.first(where: { $0.output == outputGate.inputA })!
			let inputGateB = gates.first(where: { $0.output == outputGate.inputB })!

			let xorGate: Gate
			let orGate: Gate

			if inputGateA.operation == .xor && inputGateB.operation == .or {
				xorGate = inputGateA
				orGate = inputGateB
			} else if inputGateA.operation == .or && inputGateB.operation == .xor {
				xorGate = inputGateB
				orGate = inputGateA
			} else {
				return false
			}

			guard (xorGate.inputA == xWire && xorGate.inputB == yWire) || (xorGate.inputA == yWire && xorGate.inputB == xWire) else {
				return false
			}

			let inputOrGateA = gates.first(where: { $0.output == orGate.inputA })!
			let inputOrGateB = gates.first(where: { $0.output == orGate.inputB })!

			guard inputOrGateA.operation == .and, inputOrGateB.operation == .and else {
				return false
			}

			return true
		}

//		for digitID in 3 ... 45 {
//			print("\(digitID) is valid: \(isValidGateFor(digitID: digitID))")
//		}

		// invalid gates: 12, 13, 16, 17, 24, 25, 29, 30
		// z12:
		//  x12 AND y12 -> z12
		//   -> faulty: z12
		// z13:
		//  ggr XOR hnd -> kwb
		//  ggr AND hnd -> knh
		//  kwb OR knh -> vjq
		//  x13 XOR y13 -> fgp
		//  fgp XOR vjq -> z13
		//   -> faulty: kwb
		// z16:
		//  gkw AND cmc -> z16
		//   -> faulty: z16
		// z17:
		//  cqs XOR twk -> z17
		//   -> faulty: qkf
		// z24:
		//  vhm OR wwd -> z24
		//   -> faulty: z24
		// z25:
		//  skh XOR tgr -> z25
		//   -> faulty: skh OR tgr?
		// z29:
		//  rwq XOR jqn -> z29
		//   -> faulty: jqn
		// z30:
		//  fvm XOR psc -> z30
		//   -> faulty: cph

		let faulty: [String] = [
			"cph", "jqn", "tgr", "z24", "qkf", "z16", "kwb", "z12",
		]

		return faulty.sorted().joined(separator: ",")
	}

	func parseInput(rawString: String) -> Input {
		var wires: [String: Bool] = [:]
		var gates: [Gate] = []

		var isParsingWires = true
		for line in rawString.allLines(includeEmpty: true) {
			if line.isEmpty {
				isParsingWires = false

				continue
			}

			if isParsingWires {
				let components = line.components(separatedBy: ": ")

				wires[components[0]] = Int(components[1]) == 1 ? true : false
			} else {
				let components = line.components(separatedBy: " ")

				gates.append(Gate(operation: .init(rawValue: components[1])!, inputA: components[0], inputB: components[2], output: components[4]))
			}
		}

		return .init(wires: wires, gates: gates)
	}
}
