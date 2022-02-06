import Foundation
import Tools

final class Day06Solver: DaySolver {
    let dayNumber: Int = 6

    private var input: Input!

    private struct Input {
        let instructions: [Instruction]
    }
    
    private enum Instruction {
        case on(from: Point2D, to: Point2D)
        case off(from: Point2D, to: Point2D)
        case toggle(from: Point2D, to: Point2D)
    }

    func solvePart1() -> Any {
        var grid: [Bool] = Array(repeating: false, count: 1_000 * 1_000)
        
        for instruction in input.instructions {
            // loop per state for optimized inner loop
            switch instruction {
            case .on(let from, let to):
                for y in from.y ... to.y {
                    var index = y * 1000 + from.x
                    for _ in from.x ... to.x {
                        grid[index] = true
                        
                        index += 1
                    }
                }
            case .off(let from, let to):
                for y in from.y ... to.y {
                    var index = y * 1000 + from.x
                    for _ in from.x ... to.x {
                        grid[index] = false
                        
                        index += 1
                    }
                }
            case .toggle(let from, let to):
                for y in from.y ... to.y {
                    var index = y * 1000 + from.x
                    for _ in from.x ... to.x {
                        grid[index].toggle()
                        
                        index += 1
                    }
                }
            }
        }
        
        return grid.filter { $0 }.count
    }

    func solvePart2() -> Any {
        var grid: [Int] = Array(repeating: 0, count: 1_000 * 1_000)
        
        for instruction in input.instructions {
            // loop per state for optimized inner loop
            switch instruction {
            case .on(let from, let to):
                for y in from.y ... to.y {
                    var index = y * 1000 + from.x
                    for _ in from.x ... to.x {
                        grid[index] += 1
                        
                        index += 1
                    }
                }
            case .off(let from, let to):
                for y in from.y ... to.y {
                    var index = y * 1000 + from.x
                    for _ in from.x ... to.x {
                        grid[index] = max(0, grid[index] - 1)
                        
                        index += 1
                    }
                }
            case .toggle(let from, let to):
                for y in from.y ... to.y {
                    var index = y * 1000 + from.x
                    for _ in from.x ... to.x {
                        grid[index] += 2
                        
                        index += 1
                    }
                }
            }
        }
        
        return grid.reduce(0, +)
    }

    func parseInput(rawString: String) {
        func points(from string: String) -> (Point2D, Point2D) {
            let components = string.components(separatedBy: " through ")
            
            let point1 = components[0].parseCommaSeparatedInts()
            let point2 = components[1].parseCommaSeparatedInts()
            
            return (Point2D(x: point1[0], y: point1[1]), Point2D(x: point2[0], y: point2[1]))
        }
        
        let instructions: [Instruction] = rawString.allLines().map { line in
            if line.starts(with: "turn on") {
                let points = points(from: line[8 ..< line.count])
                
                return .on(from: points.0, to: points.1)
            } else if line.starts(with: "turn off") {
                let points = points(from: line[9 ..< line.count])
                
                return .off(from: points.0, to: points.1)
            } else if line.starts(with: "toggle") {
                let points = points(from: line[7 ..< line.count])
                
                return .toggle(from: points.0, to: points.1)
            } else {
                fatalError()
            }
        }
        
        input = .init(instructions: instructions)
    }
}
