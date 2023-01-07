import Foundation
import Tools
import XCTest

final class ArrayPermutationsTests: XCTestCase {
    func testCombinationsWithoutRepetition() {
        let sut = [1, 3, 5, 7]

        var result = sut.combinationsWithoutRepetition(length: 0)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].count, 0)

        result = sut.combinationsWithoutRepetition(length: 1)

        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0], [1])
        XCTAssertEqual(result[1], [3])
        XCTAssertEqual(result[2], [5])
        XCTAssertEqual(result[3], [7])

        result = sut.combinationsWithoutRepetition(length: 2)

        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result[0], [1, 3])
        XCTAssertEqual(result[1], [1, 5])
        XCTAssertEqual(result[2], [1, 7])
        XCTAssertEqual(result[3], [3, 5])
        XCTAssertEqual(result[4], [3, 7])
        XCTAssertEqual(result[5], [5, 7])

        result = sut.combinationsWithoutRepetition(length: 3)

        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0], [1, 3, 5])
        XCTAssertEqual(result[1], [1, 3, 7])
        XCTAssertEqual(result[2], [1, 5, 7])
        XCTAssertEqual(result[3], [3, 5, 7])

        result = sut.combinationsWithoutRepetition(length: 4)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], [1, 3, 5, 7])

        result = sut.combinationsWithoutRepetition(length: 5)

        XCTAssertEqual(result.count, 0)
    }

    func testPermutations() {
        let sut = [1, 3, 5, 7]

        let result = sut.permutations

        let possiblePermutations: [[Int]] = [
            [1, 3, 5, 7],
            [1, 3, 7, 5],
            [1, 5, 3, 7],
            [1, 5, 7, 3],
            [1, 7, 3, 5],
            [1, 7, 5, 3],
            [3, 1, 5, 7],
            [3, 1, 7, 5],
            [3, 5, 1, 7],
            [3, 5, 7, 1],
            [3, 7, 1, 5],
            [3, 7, 5, 1],
            [5, 3, 1, 7],
            [5, 3, 7, 1],
            [5, 1, 3, 7],
            [5, 1, 7, 3],
            [5, 7, 3, 1],
            [5, 7, 1, 3],
            [7, 3, 5, 1],
            [7, 3, 1, 5],
            [7, 5, 3, 1],
            [7, 5, 1, 3],
            [7, 1, 3, 5],
            [7, 1, 5, 3],
        ]

        XCTAssertEqual(result.count, 24)

        XCTAssertEqual(result.filter { possiblePermutations.contains($0) }.count, 24)
    }

    func testSubsets() {
        let sut = [1, 3, 5, 7]

        var result = sut.subsets(minLength: 0, maxLength: 0)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], [])

        result = sut.subsets(minLength: 0, maxLength: 1)

        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result[0], [])
        XCTAssertEqual(result[1], [1])
        XCTAssertEqual(result[2], [3])
        XCTAssertEqual(result[3], [5])
        XCTAssertEqual(result[4], [7])

        result = sut.subsets(minLength: 0, maxLength: 2)

        XCTAssertEqual(result.count, 11)
        XCTAssertEqual(result[0], [])
        XCTAssertEqual(result[1], [1])
        XCTAssertEqual(result[2], [3])
        XCTAssertEqual(result[3], [5])
        XCTAssertEqual(result[4], [7])
        XCTAssertEqual(result[5], [1, 3])
        XCTAssertEqual(result[6], [1, 5])
        XCTAssertEqual(result[7], [1, 7])
        XCTAssertEqual(result[8], [3, 5])
        XCTAssertEqual(result[9], [3, 7])
        XCTAssertEqual(result[10], [5, 7])

        result = sut.subsets(minLength: 1, maxLength: 1)

        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0], [1])
        XCTAssertEqual(result[1], [3])
        XCTAssertEqual(result[2], [5])
        XCTAssertEqual(result[3], [7])

        result = sut.subsets(minLength: 1, maxLength: 2)

        XCTAssertEqual(result.count, 10)
        XCTAssertEqual(result[0], [1])
        XCTAssertEqual(result[1], [3])
        XCTAssertEqual(result[2], [5])
        XCTAssertEqual(result[3], [7])
        XCTAssertEqual(result[4], [1, 3])
        XCTAssertEqual(result[5], [1, 5])
        XCTAssertEqual(result[6], [1, 7])
        XCTAssertEqual(result[7], [3, 5])
        XCTAssertEqual(result[8], [3, 7])
        XCTAssertEqual(result[9], [5, 7])

        result = sut.subsets(minLength: 2, maxLength: 2)

        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result[0], [1, 3])
        XCTAssertEqual(result[1], [1, 5])
        XCTAssertEqual(result[2], [1, 7])
        XCTAssertEqual(result[3], [3, 5])
        XCTAssertEqual(result[4], [3, 7])
        XCTAssertEqual(result[5], [5, 7])
    }
}
