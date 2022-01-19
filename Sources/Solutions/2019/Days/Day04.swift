import Foundation
import Tools

final class Day04Solver: DaySolver {
    let dayNumber: Int = 4

    private var input: Input!

    private struct Input {
        let range: ClosedRange<Int>
    }

    func solvePart1() -> Any {
        let aLowerBound = input.range.lowerBound / 100_000
        let aUpperBound = input.range.upperBound / 100_000

        var possiblePasswords: [Int] = []

        for a in aLowerBound ... aUpperBound {
            for b in a ... 9 {
                for c in b ... 9 {
                    for d in c ... 9 {
                        for e in d ... 9 {
                            for f in e ... 9 where (a == b) || (b == c) || (c == d) || (d == e) || (e == f) {
                                let password = a * 100000 + b * 10000 + c * 1000 + d * 100 + e * 10 + f

                                if input.range.contains(password) {
                                    possiblePasswords.append(password)
                                }
                            }
                        }
                    }
                }
            }
        }

        return possiblePasswords.count
    }

    func solvePart2() -> Any {
        let aLowerBound = input.range.lowerBound / 100_000
        let aUpperBound = input.range.upperBound / 100_000

        var possiblePasswords: [Int] = []

        for a in aLowerBound ... aUpperBound {
            for b in a ... 9 {
                for c in b ... 9 {
                    for d in c ... 9 {
                        for e in d ... 9 {
                            for f in e ... 9 {
                                let hasPair = (a == b && a != c)
                                    || (b == c && a != b && d != c)
                                    || (c == d && b != c && e != d)
                                    || (d == e && c != d && f != e)
                                    || (e == f && d != e)

                                guard hasPair else {
                                    continue
                                }

                                let password = a * 100000 + b * 10000 + c * 1000 + d * 100 + e * 10 + f

                                if input.range.contains(password) {
                                    possiblePasswords.append(password)
                                }
                            }
                        }
                    }
                }
            }
        }

        return possiblePasswords.count
    }

    func parseInput(rawString: String) {
        input = .init(range: 307237 ... 769058)
    }
}
