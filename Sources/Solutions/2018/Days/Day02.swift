import Foundation
import Tools

final class Day02Solver: DaySolver {
    let dayNumber: Int = 2

    let expectedPart1Result = 6000
    let expectedPart2Result = "pbykrmjmizwhxlqnasfgtycdv"

    private var input: Input!

    private struct Input {
        let boxIds: [String]
    }

    func solvePart1() -> Int {
        var twoCounter = 0
        var threeCounter = 0

        for id in input.boxIds {
            var counter: [String: Int] = [:]

            for char in id {
                counter[String(char), default: 0] += 1
            }

            twoCounter += Set(counter.values).contains(2) ? 1 : 0
            threeCounter += Set(counter.values).contains(3) ? 1 : 0
        }

        return twoCounter * threeCounter
    }

    func solvePart2() -> String {
        for i in 0 ..< input.boxIds.count {
            for j in i + 1 ..< input.boxIds.count {
                let a = input.boxIds[i]
                let b = input.boxIds[j]

                assert(a.count == b.count)

                var differenceIndex: Int?
                for k in 0 ..< a.count {
                    if a[k] != b[k] {
                        if differenceIndex != nil {
                            differenceIndex = nil

                            break
                        }

                        differenceIndex = k
                    }
                }

                if let differenceIndex {
                    var characters = a.map { String($0) }

                    characters.remove(at: differenceIndex)

                    return characters.joined()
                }
            }
        }

        fatalError()
    }

    func parseInput(rawString: String) {
        input = .init(boxIds: rawString.allLines())
    }
}
