import Foundation
import Tools

final class Day01Solver: DaySolver {
    let dayNumber: Int = 1

    private var input: Input!

    private struct Input {
        let depths: [Int]
    }

    func solvePart1() -> Any {
        let result: (counter: Int, previousDepth: Int?) = input.depths.reduce(into: (counter: 0, previousDepth: nil), { result, depth in
            if let previousDepth = result.previousDepth {
                result.counter += depth > previousDepth ? 1 : 0
            }

            result.previousDepth = depth
        })

        return result.counter
    }

    func solvePart2() -> Any {
        var result: (counter: Int, slidingWindow: [Int]) = (0, [])

        result = input.depths.reduce(into: result, { result, depth in
            guard result.slidingWindow.count >= 3 else {
                result.slidingWindow.append(depth)

                return
            }

            let sumA = result.slidingWindow.reduce(0, +)

            result.slidingWindow.removeFirst()
            result.slidingWindow.append(depth)

            let sumB = result.slidingWindow.reduce(0, +)

            result.counter += sumB > sumA ? 1 : 0
        })

        return result.counter        
    }

    func parseInput(rawString: String) {
        let depths = rawString.components(separatedBy: .newlines).compactMap { Int($0) }

        input = .init(depths: depths)
    }
}
