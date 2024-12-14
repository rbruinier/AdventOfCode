import Foundation
import Tools

final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	struct Input {
		let elves: Set<Point2D>
	}

	init() {}

	func performAlgorithm(elves: Set<Point2D>, maxRounds: Int?) -> (rounds: Int, emptyTiles: Int) {
		var currentElves = elves
		var currentStartMoveIndex = 0

		let maxRounds = maxRounds ?? Int.max

		var roundIndex = 0

		while roundIndex < maxRounds {
			roundIndex += 1

			var proposedMoves: [Point2D: Direction] = [:]

			elfLoop: for elf in currentElves {
				var hasNeighbor = false

				for neighbors in elf.neighbors(includingDiagonals: true) {
					if currentElves.contains(neighbors) {
						hasNeighbor = true

						break
					}
				}

				if !hasNeighbor {
					continue elfLoop
				}

				for moveIndex in currentStartMoveIndex ..< currentStartMoveIndex + 4 {
					let currentMoveIndex = moveIndex % 4

					let pointsToCheck: Set<Point2D>

					let proposedMove: Direction
					switch currentMoveIndex {
					case 0:
						pointsToCheck = [elf.moved(to: .north), elf.moved(to: .northWest), elf.moved(to: .northEast)]
						proposedMove = .north
					case 1:
						pointsToCheck = [elf.moved(to: .south), elf.moved(to: .southWest), elf.moved(to: .southEast)]
						proposedMove = .south
					case 2:
						pointsToCheck = [elf.moved(to: .west), elf.moved(to: .northWest), elf.moved(to: .southWest)]
						proposedMove = .west
					case 3:
						pointsToCheck = [elf.moved(to: .east), elf.moved(to: .northEast), elf.moved(to: .southEast)]
						proposedMove = .east
					default:
						fatalError()
					}

					var isAvailable = true

					for pointToCheck in pointsToCheck {
						if currentElves.contains(pointToCheck) {
							isAvailable = false

							break
						}
					}

					if isAvailable {
						proposedMoves[elf] = proposedMove

						break
					}
				}
			}

			var newElves: Set<Point2D> = []

			var newProposedPositions: [Point2D: Int] = [:]

			for (elf, proposedMove) in proposedMoves {
				let newElf = elf.moved(to: proposedMove)

				newProposedPositions[newElf, default: 0] += 1
			}

			for elf in currentElves {
				if let proposedMove = proposedMoves[elf] {
					let newElf = elf.moved(to: proposedMove)

					if newProposedPositions[newElf]! == 1 {
						newElves.insert(newElf)
					} else {
						newElves.insert(elf)
					}
				} else {
					newElves.insert(elf)
				}
			}

			if newElves == currentElves {
				break
			}

			currentElves = newElves
			currentStartMoveIndex = (currentStartMoveIndex + 1) % 4
		}

		let minX = currentElves.map(\.x).min()!
		let maxX = currentElves.map(\.x).max()! + 1

		let minY = currentElves.map(\.y).min()!
		let maxY = currentElves.map(\.y).max()! + 1

		let emptyTiles = ((maxY - minY) * (maxX - minX)) - currentElves.count

		//		for y in minY ... maxY {
		//			var line = ""
		//			for x in minX ... maxX {
		//				line += currentElves.contains(.init(x: x, y: y)) ? "#" : "."
		//			}
		//			print(line)
		//		}

		return (rounds: roundIndex, emptyTiles: emptyTiles)
	}

	func solvePart1(withInput input: Input) -> Int {
		performAlgorithm(elves: input.elves, maxRounds: 10).emptyTiles
	}

	func solvePart2(withInput input: Input) -> Int {
		performAlgorithm(elves: input.elves, maxRounds: nil).rounds
	}

	func parseInput(rawString: String) -> Input {
		var elves: Set<Point2D> = []

		for (y, line) in rawString.allLines().enumerated() {
			for (x, char) in line.enumerated() {
				if char == "#" {
					elves.insert(.init(x: x, y: y))
				}
			}
		}

		return .init(elves: elves)
	}
}
