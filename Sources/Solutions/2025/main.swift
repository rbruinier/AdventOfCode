import Foundation
import Tools

var yearSolver = YearSolver(year: 2025)

//yearSolver.addSolver(Day01Solver())
//yearSolver.addSolver(Day02Solver())
//yearSolver.addSolver(Day03Solver())
//yearSolver.addSolver(Day04Solver())
yearSolver.addSolver(Day05Solver())
//yearSolver.addSolver(Day06Solver())
//yearSolver.addSolver(Day07Solver())
//yearSolver.addSolver(Day08Solver())
//yearSolver.addSolver(Day09Solver())
//yearSolver.addSolver(Day10Solver())
//yearSolver.addSolver(Day11Solver())
//yearSolver.addSolver(Day12Solver())

await solveYear(yearSolver, dayNumber: nil, bundle: .module)
