import Foundation
import Tools

print("Advent of Code 2021 🎄")

let days: [DaySolver] = [
//    Day01Solver(),
//    Day02Solver(),
//    Day03Solver(),
//    Day04Solver(),
//    Day05Solver(),
//    Day06Solver(),
//    Day07Solver(),
//    Day08Solver(),
//    Day09Solver(),
//    Day10Solver(),
//    Day11Solver(),
//    Day12Solver(),
//    Day13Solver(),
//    Day14Solver(),
//    Day15Solver(),
//    Day16Solver(),
//    Day17Solver(),
//    Day18Solver(),
//    Day19Solver(),
//    Day20Solver(),
//    Day21Solver(),
//    Day22Solver(),
    Day23Solver(),
//    Day24Solver(),
//    Day25Solver()
]

print("Parsing inputs")

days.forEach { day in
    day.parseInput(rawString: getRawInputStringFor(day: day.dayNumber, in: .module))
}

print("Start solving days")

let startTime = mach_absolute_time()

days.forEach { day in
    solveDay(day)
}

let formattedDuration = String(format: "%.4f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

print("Total running duration is \(formattedDuration) seconds")

//let exportPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop/AdventOfCode/2021/23")
//
//try! FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true)
//
//if let visualizable: Visualizable = days.compactMap({ $0 as? Visualizable }).first {
//	let visualizer = visualizable.createVisualizer()
//	
//	var result: VisualizableResult
//	
//	repeat {
//		result = visualizable.visualizeState(with: visualizer)
//		
//		visualizer.exportFrameToPNG(rootPath: exportPath.relativePath)
//	} while result == .ready
//}
