import Foundation
import Tools

let yearsSolver = YearSolver(
	year: 2024,
	days: [
		Day01Solver(),
		Day02Solver(),
		Day03Solver(),
		Day04Solver(),
		Day05Solver(),
		Day06Solver(),
		Day07Solver(),
		Day08Solver(),
		Day09Solver(),
		Day10Solver(),
		Day11Solver(),
		Day12Solver(),
		Day13Solver(),
		Day14Solver(),
		Day15Solver(),
		Day16Solver(),
		Day17Solver(),
		Day18Solver(),
		Day19Solver(),
		Day20Solver(),
		Day21Solver(),
		Day22Solver(),
		Day23Solver(),
		Day24Solver(),
		Day25Solver(),
	]
)

await solveYear(yearsSolver, dayNumber: 13, bundle: .module)
