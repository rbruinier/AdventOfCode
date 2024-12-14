import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	struct Input {
		let seats: [String]
	}

	private func getSeatID(from seatCode: String) -> Int {
		var seat = seatCode

		var lowRow = 0
		var highRow = 127

		for _ in 0 ..< 7 {
			let letter = seat.removeFirst()

			switch letter {
			case "F": highRow -= ((highRow - lowRow) / 2) + 1
			case "B": lowRow += ((highRow - lowRow) / 2) + 1
			default: fatalError()
			}
		}

		var lowSeat = 0
		var highSeat = 7

		for _ in 0 ..< 3 {
			let letter = seat.removeFirst()

			switch letter {
			case "R": lowSeat += ((highSeat - lowSeat) / 2) + 1
			case "L": highSeat -= ((highSeat - lowSeat) / 2) + 1
			default: fatalError()
			}
		}

		return lowRow * 8 + lowSeat
	}

	func solvePart1(withInput input: Input) -> Int {
		var highestSeatID = 0

		for seatCode in input.seats {
			let seatID = getSeatID(from: seatCode)

			highestSeatID = max(seatID, highestSeatID)
		}

		return highestSeatID
	}

	func solvePart2(withInput input: Input) -> Int {
		let seatIDs: [Int] = input.seats.map { getSeatID(from: $0) }

		let lowestSeatID = seatIDs.min()!
		let highestSeatID = seatIDs.max()!

		for seatID in lowestSeatID + 1 ..< highestSeatID {
			if seatIDs.contains(seatID) == false {
				return seatID
			}
		}

		return 0
	}

	func parseInput(rawString: String) -> Input {
		let seats = rawString.allLines()

		return .init(seats: seats)
	}
}
