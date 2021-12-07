import Foundation

public struct Input {
    let positions: [Int]
}

public func solutionFor(input: Input) -> Int {
    let sortedPositions = input.positions.sorted()

    let median = sortedPositions[input.positions.count >> 1]

    let fuelUsage = input.positions.reduce(0) { result, position in
        result + abs(position - median)
    }
    
    return fuelUsage
}
