import Foundation
import Tools

final class Day18Solver: DaySolver {
    let dayNumber: Int = 18

    private var input: Input!

    private struct Input {
        var grid: [Bool]

        let width: Int = 100
        let height: Int = 100
    }

    private func updateGrid(_ grid: [Bool], width: Int, height: Int)  -> [Bool] {
        var result = grid

        var index = 0
        for y in 0 ..< height {
            for x in 0 ..< width {
                var neighbors = 0

                for innerY in max(0, y - 1) ... min(height - 1, y + 1) {
                    for innerX in max(0, x - 1) ... min(width - 1, x + 1) {
                        if innerY == y && innerX == x {
                            continue
                        }

                        neighbors += grid[innerY * width + innerX] ? 1 : 0
                    }
                }

                if grid[index] {
                    if neighbors < 2 || neighbors > 3 {
                        result[index] = false
                    }
                } else {
                    if neighbors == 3 {
                        result[index] = true
                    }
                }

                index += 1
            }
        }

        return result
    }

    func solvePart1() -> Any {
        var grid = input.grid

        for _ in 0 ..< 100 {
            grid = updateGrid(grid, width: input.width, height: input.height)
        }

        return grid.filter { $0 }.count
    }


    func solvePart2() -> Any {
        var grid = input.grid

        for step in 0 ... 100 {
            grid[0] = true
            grid[input.width - 1] = true
            grid[(input.height - 1) * input.width] = true
            grid[(input.width * input.height) - 1] = true

            if step < 100 {
                grid = updateGrid(grid, width: input.width, height: input.height)
            }
        }

        return grid.filter { $0 }.count
    }

    func parseInput(rawString: String) {
        let grid: [Bool] = rawString.allLines().joined().map { $0 == "#" ? true : false }

        input = .init(grid: grid)
    }
}
