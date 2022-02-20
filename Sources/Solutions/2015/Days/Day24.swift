import Foundation
import Tools

final class Day24Solver: DaySolver {
    let dayNumber: Int = 24

    private var input: Input!

    private struct Input {
        let weights: [Int]
    }

    func findAllGroupsWithWeight(items: [Int], groupWeight: Int) -> [[Int]] {
        for length in 1 ..< items.count {
            let combinations = items.combinationsWithoutRepetition(length: length)

            let matches = combinations.filter { combo in
                combo.reduce(0, +) == groupWeight
            }

            if matches.isNotEmpty {
                return matches
            }
        }

        return []
    }

    func solvePart1() -> Any {
        let weights = input.weights

        let totalWeight = weights.reduce(0, +)
        let groupWeight = totalWeight / 3

        let groups = findAllGroupsWithWeight(items: weights, groupWeight: groupWeight)

        return groups.map { items in
            items.reduce(1, *)
        }.sorted().first!
    }

    func solvePart2() -> Any {
        let weights = input.weights

        let totalWeight = weights.reduce(0, +)
        let groupWeight = totalWeight / 4

        let groups = findAllGroupsWithWeight(items: weights, groupWeight: groupWeight)

        return groups.map { items in
            items.reduce(1, *)
        }.sorted().first!
    }

    func parseInput(rawString: String) {
        input = .init(weights: rawString.allLines().map { Int($0)! })
    }
}
