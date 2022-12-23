import Foundation
@testable import Solutions2022
import Tools
import XCTest

final class SolverTests: XCTestCase {
    func testSolver() {
        let solver = Day22Solver()

        solver.parseInput(rawString: getRawInputStringFor(day: solver.dayNumber, in: .module))

        XCTAssertEqual(solver.solvePart1(), solver.expectedPart1Result)
        XCTAssertEqual(solver.solvePart2(), solver.expectedPart2Result)
    }
}
