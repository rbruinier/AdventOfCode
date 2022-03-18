import Collections
import Foundation
import Tools

final class Day11Solver: DaySolver {
	let dayNumber = 11

	private var input: Input!

	private struct Input {
	}
	
	private struct Element: Hashable {
		var id: String
		
		var generatorFloor: Int
		var chipFloor: Int
		
		var isCompleted: Bool {
			generatorFloor == 3 && chipFloor == 3
		}
		
		var isPaired: Bool {
			generatorFloor == chipFloor
		}
		
		func chipIsOnFloor(_ floor: Int) -> Bool {
			chipFloor == floor
		}
		
		func generatorIsOnFloor(_ floor: Int) -> Bool {
			generatorFloor == floor
		}
		
		func isOnFloor(_ floor: Int) -> Bool {
			chipFloor == floor || generatorFloor == floor
		}
	}
	
	private struct State: Hashable, CustomStringConvertible {
		let floor: Int
		
		let elements: [Element]
		
		var isFinished: Bool {
			elements.allSatisfy { $0.isCompleted }
		}
		
		var isValid: Bool {
			for floor in 0 ... 3 {
				if chipsOnFloor(floor).contains(where: { $0.isPaired == false }) && generatorsOnFloor(floor).isNotEmpty {
					return false
				}
			}
			
			return true
		}
		
		func chipsOnFloor(_ floor: Int) -> [Element] {
			return elements.filter {
				$0.chipFloor == floor
			}
		}

		func generatorsOnFloor(_ floor: Int) -> [Element] {
			return elements.filter {
				$0.generatorFloor == floor
			}
		}

		func isEmptyFloor(_ floor: Int) -> Bool {
			return chipsOnFloor(floor).isEmpty && generatorsOnFloor(floor).isEmpty
		}
		
		func validNextStates(handled: Set<State>) -> [State] {
			var newStates: Set<State> = []
			
			for floor in (max(0, self.floor - 1) ... min(3, self.floor + 1)).reversed() where floor != self.floor {
				for i in 0 ..< elements.count {
					for j in i ..< elements.count { // include original index so we also have single items
						// generators
						var newElements = elements
						
						if newElements[i].generatorFloor == self.floor, newElements[i].isCompleted == false {
							newElements[i].generatorFloor = floor
						}
						
						if newElements[j].generatorFloor == self.floor, newElements[j].isCompleted == false {
							newElements[j].generatorFloor = floor
						}
						
						if newElements != elements {
							let newState = State(floor: floor, elements: newElements)
							
							if newState.isValid, handled.contains(newState) == false {
								newStates.insert(newState)
							}
						}

						// chips
						newElements = elements
						
						if newElements[i].chipFloor == self.floor, newElements[i].isCompleted == false {
							newElements[i].chipFloor = floor
						}
						
						if newElements[j].chipFloor == self.floor, newElements[j].isCompleted == false {
							newElements[j].chipFloor = floor
						}
						
						if newElements != elements {
							let newState = State(floor: floor, elements: newElements)
							
							if newState.isValid, handled.contains(newState) == false {
								newStates.insert(newState)
							}
						}
					}
					
					// generator & chip
					var newElements = elements

					if newElements[i].isPaired, newElements[i].isCompleted == false, newElements[i].generatorFloor == self.floor, floor > self.floor {
						newElements[i].generatorFloor = floor
						newElements[i].chipFloor = floor
					}

					if newElements != elements {
						let newState = State(floor: floor, elements: newElements)
						
						if newState.isValid, handled.contains(newState) == false {
							newStates.insert(newState)
						}
					}
				}
			}
			
			return Array(newStates)
		}
	}
	
	private func solve(with originalState: State) -> Int {
		struct Step {
			let nrOfSteps: Int
			let state: State
		}

		var queue: Deque<Step> = [.init(nrOfSteps: 0, state: originalState)]
		var handledStates: Set<State> = []
		var minimumSteps = Int.max

		while let step = queue.popFirst() {
			let state = step.state

			if state.isFinished {
				minimumSteps = min(minimumSteps, step.nrOfSteps)
				
				continue
			}

			for nextState in state.validNextStates(handled: handledStates) where handledStates.contains(nextState) == false {
				handledStates.insert(nextState)
				
				queue.append(.init(nrOfSteps: step.nrOfSteps + 1, state: nextState))
			}
		}

		return minimumSteps
	}
	
	func solvePart1() -> Any {
		let state = State(floor: 0, elements: [
			.init(id: "polonium", generatorFloor: 0, chipFloor: 0),
			.init(id: "thulium", generatorFloor: 0, chipFloor: 0),
			.init(id: "ruthenium", generatorFloor: 0, chipFloor: 0),
			.init(id: "polonium", generatorFloor: 0, chipFloor: 1),
			.init(id: "promethium", generatorFloor: 0, chipFloor: 1),
		])

		return solve(with: state)
	}

	func solvePart2() -> Any {
		let state = State(floor: 0, elements: [
			.init(id: "elerium", generatorFloor: 0, chipFloor: 0),
			.init(id: "dilithium", generatorFloor: 0, chipFloor: 0),
			.init(id: "polonium", generatorFloor: 0, chipFloor: 0),
			.init(id: "thulium", generatorFloor: 0, chipFloor: 0),
			.init(id: "ruthenium", generatorFloor: 0, chipFloor: 0),
			.init(id: "polonium", generatorFloor: 0, chipFloor: 1),
			.init(id: "promethium", generatorFloor: 0, chipFloor: 1),
		])
		
		return solve(with: state)
	}

	func parseInput(rawString: String) {
	}
}
