import Foundation
import Tools

final class Day20Solver: DaySolver {
	let dayNumber: Int = 20

	typealias Modules = [String: Module]

	private let broadcasterID = "broadcaster"

	struct Input {
		let modules: Modules
	}

	enum ModuleType {
		case flipFlop
		case remember
		case broadcast
	}

	struct Module {
		let type: ModuleType
		let destinations: [String]
	}

	private enum Signal {
		case low
		case high
	}

	private struct State {
		var onFlipFlopModules: Set<String> = []
		var rememberModules: [String: [String: Signal]] = [:]

		var lowPulseCount = 0
		var highPulseCount = 0

		var repeatingCycles: [String: Int] = [:]

		var buttonPressCount = 0
	}

	private struct Configuration {
		let flipFlopModuleIDs: Set<String>
		let rememberModuleIDs: Set<String>

		let checkForRepeatingCyclesOfRememberModuleID: String?
	}

	private struct Pulse {
		let signal: Signal
		let destinationID: String
		let originID: String
	}

	private func initializeRememberStates(with modules: Modules, state: inout State, configuration: Configuration) {
		for rememberModuleID in configuration.rememberModuleIDs {
			state.rememberModules[rememberModuleID] = [:]

			for inputID in modules.filter({ $0.value.destinations.contains(rememberModuleID) }).map(\.key) {
				state.rememberModules[rememberModuleID]![inputID] = .low
			}
		}
	}

	private func pressButton(on modules: Modules, state: inout State, configuration: Configuration) {
		var pulses: [Pulse] = []

		for destination in modules[broadcasterID]!.destinations {
			pulses.append(.init(signal: .low, destinationID: destination, originID: broadcasterID))
		}

		state.lowPulseCount += 1

		while pulses.isNotEmpty {
			state.lowPulseCount += pulses.filter { $0.signal == .low }.count
			state.highPulseCount += pulses.filter { $0.signal == .high }.count

			var newPulses: [Pulse] = []

			for pulse in pulses {
				// there are unknown module destinations
				guard let module = modules[pulse.destinationID] else {
					continue
				}

				switch module.type {
				case .broadcast: preconditionFailure()
				case .flipFlop:
					let sendSignal: Signal

					switch pulse.signal {
					case .high:
						break
					case .low:
						if state.onFlipFlopModules.contains(pulse.destinationID) {
							state.onFlipFlopModules.remove(pulse.destinationID)
							sendSignal = .low
						} else {
							state.onFlipFlopModules.insert(pulse.destinationID)
							sendSignal = .high
						}

						for destination in module.destinations {
							newPulses.append(.init(signal: sendSignal, destinationID: destination, originID: pulse.destinationID))
						}
					}
				case .remember:
					state.rememberModules[pulse.destinationID]![pulse.originID]! = pulse.signal

					if 
						let checkForRepeatingCyclesOfRememberModuleID = configuration.checkForRepeatingCyclesOfRememberModuleID,
						pulse.destinationID == checkForRepeatingCyclesOfRememberModuleID,
						pulse.signal == .high,
						!state.repeatingCycles.keys.contains(pulse.originID)
					{
						state.repeatingCycles[pulse.originID] = state.buttonPressCount
					}

					let sendSignal: Signal = state.rememberModules[pulse.destinationID]!.values.allSatisfy { $0 == .high } ? .low : .high

					for destination in module.destinations {
						newPulses.append(.init(signal: sendSignal, destinationID: destination, originID: pulse.destinationID))
					}
				}
			}

			pulses = newPulses
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		let configuration = Configuration(
			flipFlopModuleIDs: Set(input.modules.filter { $0.value.type == .flipFlop }.map(\.key)),
			rememberModuleIDs: Set(input.modules.filter { $0.value.type == .remember }.map(\.key)),
			checkForRepeatingCyclesOfRememberModuleID: nil
		)

		var state = State()

		initializeRememberStates(with: input.modules, state: &state, configuration: configuration)

		for _ in 0 ..< 1000 {
			pressButton(on: input.modules, state: &state, configuration: configuration)
		}

		return state.lowPulseCount * state.highPulseCount
	}

	func solvePart2(withInput input: Input) -> Int {
		// Cycle detection... might only work for my input:
		//
		// &jq -> rx
		//
		// jq fires low signal if all of these four inputs are on: vr, nl, lr & gt

		let rxInputModuleID = input.modules.first { $0.value.destinations.contains("rx") }.map(\.key)!

		let configuration = Configuration(
			flipFlopModuleIDs: Set(input.modules.filter { $0.value.type == .flipFlop }.map(\.key)),
			rememberModuleIDs: Set(input.modules.filter { $0.value.type == .remember }.map(\.key)),
			checkForRepeatingCyclesOfRememberModuleID: rxInputModuleID
		)

		var state = State()

		initializeRememberStates(with: input.modules, state: &state, configuration: configuration)

		while true {
			state.buttonPressCount += 1

			pressButton(on: input.modules, state: &state, configuration: configuration)

			if state.repeatingCycles.count == state.rememberModules[rxInputModuleID]!.count {
				break
			}
		}

		return Math.leastCommonMultiple(for: state.repeatingCycles.values.map { $0 })
	}

	func parseInput(rawString: String) -> Input {
		var modules: Modules = [:]

		for line in rawString.allLines() {
			let components = line.components(separatedBy: " -> ")

			let id: String
			let moduleType: ModuleType

			if components[0].hasPrefix(broadcasterID) {
				id = broadcasterID
				moduleType = .broadcast
			} else {
				id = String(components[0].dropFirst())

				switch components[0].first! {
				case "%": moduleType = .flipFlop
				case "&": moduleType = .remember
				default: preconditionFailure()
				}
			}

			modules[id] = .init(type: moduleType, destinations: components[1].components(separatedBy: ", "))
		}

		return .init(modules: modules)
	}
}
