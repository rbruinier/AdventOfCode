import Foundation

final class Day15Solver: DaySolver {
    let dayNumber: Int = 15

    private var input: Input!

    private struct Input {
        let riskLevels: [Int]

        let width: Int
        let height: Int
    }

    private struct Coordinate: Equatable, Hashable {
        var x: Int
        var y: Int
    }

    private func solve(riskLevels: [Int], width: Int, height: Int) -> Int {
        // credits to the idea to this reddit post: https://www.reddit.com/r/adventofcode/comments/rh5vgv/comment/hoppwtt/?utm_source=share&utm_medium=web2x&context=3

        var minimumRiskGrid: [Int] = Array(repeating: Int.max >> 1, count: width * height)

        minimumRiskGrid[0] = 0

        var computing = true

        while computing {
            computing = false

            for y in 0 ..< height {
                for x in 0 ..< width {
                    let n = Coordinate(x: x, y: y - 1)
                    let s = Coordinate(x: x, y: y + 1)
                    let w = Coordinate(x: x - 1, y: y)
                    let e = Coordinate(x: x + 1, y: y)

                    let coordinates: [Coordinate] = [n, s, w, e].filter { coordinate in
                        coordinate.x >= 0 && coordinate.x < width && coordinate.y >= 0 && coordinate.y < height
                    }

                    let minNeighborRisk = coordinates.map { minimumRiskGrid[($0.y * width) + $0.x] }.min()!

                    let potential = minNeighborRisk + riskLevels[y * width + x]

                    if potential < minimumRiskGrid[(y * width) + x] {
                        minimumRiskGrid[y * width + x]  = potential

                        computing = true
                    }
                }
            }
        }

        return minimumRiskGrid.last!
    }

    func solvePart1() -> Any {
        return solve(riskLevels: input.riskLevels, width: input.width, height: input.height)
    }

    func solvePart2() -> Any {
        var riskLevels: [Int] = Array(repeating: 0, count: input.riskLevels.count * 25)

        let width = input.width * 5
        let height = input.height * 5

        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                let originalRiskLevel = input.riskLevels[y * input.width + x]

                for repeatingY in 0 ..< 5 {
                    let actualY = y + (repeatingY * input.height)

                    for repeatingX in 0 ..< 5 {
                        let actualX = x + (repeatingX * input.width)

                        let newRisk = (((originalRiskLevel + repeatingY + repeatingX) - 1) % 9) + 1

                        riskLevels[actualY * width + actualX] = newRisk
                    }
                }
            }
        }

        return solve(riskLevels: riskLevels, width: width, height: height)
    }

    func parseInput(rawString: String) {
        let height = rawString.filter { $0.isNewline }.count

        let riskLevels: [Int] = rawString
            .compactMap { Int(String($0)) }

        let width = riskLevels.count / height

        input = .init(riskLevels: riskLevels, width: width, height: height)
    }
}
