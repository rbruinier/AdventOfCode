import Foundation
import Tools

final class Day03Solver: DaySolver {
    let dayNumber: Int = 3
    
    private var input: Input!

    private struct Input {
        let grid: [Bool]

        let width: Int
        let height: Int
    }

    func solvePart1() -> Any {
        var x = 0
        var y = 0

        var counter = 0
        while y < input.height {
            counter += input.grid[y * input.width + x] ? 1 : 0

            x = (x + 3) % input.width
            y += 1
        }

        return counter
    }

    func solvePart2() -> Any {
        let slopes: [(x: Int, y: Int)] = [
            (x: 1, y: 1),
            (x: 3, y: 1),
            (x: 5, y: 1),
            (x: 7, y: 1),
            (x: 1, y: 2),
        ]

        var combined = 1
        for slope in slopes {
            var x = 0
            var y = 0

            var counter = 0
            while y < input.height {
                counter += input.grid[y * input.width + x] ? 1 : 0

                x = (x + slope.x) % input.width
                y += slope.y
            }

            combined *= counter
        }

        return combined
    }

    func parseInput(rawString: String) {
        let lines = rawString.allLines()

        let grid: [Bool] = lines.flatMap { $0.map { $0 == "#" ? true : false }}

        let width = grid.count / lines.count
        let height = lines.count

        input = .init(grid: grid, width: width, height: height)
    }
}
