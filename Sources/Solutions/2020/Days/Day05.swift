import Foundation
import Tools

final class Day05Solver: DaySolver {
    let dayNumber: Int = 5

    private var input: Input!

    private struct Input {
        let seats: [String]
    }

    private func getSeatId(from seatCode: String) -> Int {
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

    func solvePart1() -> Any {
        var highestSeatId = 0

        for seatCode in input.seats {
            let seatId = getSeatId(from: seatCode)

            highestSeatId = max(seatId, highestSeatId)
        }

        return highestSeatId
    }

    func solvePart2() -> Any {
        let seatIds: [Int] = input.seats.map { getSeatId(from: $0) }

        let lowestSeatId = seatIds.min()!
        let highestSeatId = seatIds.max()!

        for seatId in lowestSeatId + 1 ..< highestSeatId {
            if seatIds.contains(seatId) == false {
                return seatId
            }
        }

        return 0
    }

    func parseInput(rawString: String) {
        let seats = rawString.allLines()
        
        input = .init(seats: seats)
    }
}
