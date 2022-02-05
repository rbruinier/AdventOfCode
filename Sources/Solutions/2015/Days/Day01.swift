import Foundation
import Tools

final class Day01Solver: DaySolver {
    let dayNumber: Int = 1

    private var input: Input!

    private struct Input {
        let line: String
    }

    func solvePart1() -> Any {
        return input.line.filter { $0 == "(" }.count - input.line.filter { $0 == ")" }.count
    }

    func solvePart2() -> Any {
        var level = 0
        for (index, character) in input.line.enumerated() {
            if character == "(" {
                level += 1
            } else if character == ")" {
                level -= 1
            }

            if level == -1 {
                return index + 1
            }
        }
        
        return 0
    }

    func parseInput(rawString: String) {
        input = .init(line: rawString.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
