import Foundation
import Tools

final class Day06Solver: DaySolver {
    let dayNumber: Int = 6

    private var input: Input!

    private struct Input {
        let buffer: String
    }

    private func scan(buffer: String, count: Int) -> Int {
        var lastCharacters: [String] = []

        for i in 0 ..< input.buffer.count {
            if lastCharacters.count == count {
                lastCharacters.removeFirst()
            }

            lastCharacters.append(input.buffer[i])

            if Set(lastCharacters).count == count {
                return 1 + i
            }
        }

        fatalError()
    }

    func solvePart1() -> Any {
        scan(buffer: input.buffer, count: 4)
    }

    func solvePart2() -> Any {
        scan(buffer: input.buffer, count: 14)
    }

    func parseInput(rawString: String) {
        input = .init(buffer: rawString.allLines().first!)
    }
}
