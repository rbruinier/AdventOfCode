import Foundation

final class Day10Solver: DaySolver {
    let dayNumber: Int = 10

    private var input: Input!

    private struct Input {
        let adapters: [Int]
    }

    private func possibleCombinations(from index: Int, adapters: [Int], cache: inout [Int: Int]) -> Int {
        if let sum = cache[index] {
            return sum
        }

        var nextIndices: [Int] = []

        for nextIndex in index + 1 ..< adapters.count {
            if adapters[nextIndex] - adapters[index] <= 3 {
                nextIndices.append(nextIndex)
            } else {
                break
            }
        }

        if nextIndices.isEmpty {
            return 1
        }

        let sum = nextIndices.reduce(0) { result, nextIndex in
            result + possibleCombinations(from: nextIndex, adapters: adapters, cache: &cache)
        }

        cache[index] = sum

        return sum
    }
    
    func solvePart1() -> Any {
        let adapters = input.adapters.sorted()

        var sum = adapters[0] + 3
        var joltCount: [Int: Int] = [
            adapters[0]: 1,
            2: 0,
            3: 1
        ]

        for index in 1 ..< adapters.count {
            let jolt = adapters[index] - adapters[index - 1]

            joltCount[jolt, default: 0] += 1

            sum += jolt
        }
        
        return joltCount[1]! * joltCount[3]!
    }

    func solvePart2() -> Any {
        var cache: [Int: Int] = [:]

        let adapters = [0] + input.adapters.sorted()

        return possibleCombinations(from: 0, adapters: adapters, cache: &cache)
    }

    func parseInput(rawString: String) {
        let adapters = rawString.components(separatedBy: .newlines).compactMap { Int($0) }

        input = .init(adapters: adapters)
    }
}

