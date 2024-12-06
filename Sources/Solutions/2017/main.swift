import Foundation
import Tools

print("Advent of Code 2017 🎄")

extension DaySolver {
	var year: Int {
		2017
	}
}

let day11Solver = Day11Solver()

let days: [any DaySolver] = [
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
	day11Solver,
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

await solveDays(days, bundle: .module)

// visualize(
//	solver: day11Solver,
//	rootPath: FileManager.default
//		.homeDirectoryForCurrentUser
//		.appendingPathComponent("Desktop/AdventOfCode")
// )
