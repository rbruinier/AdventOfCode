import Foundation

public struct Input {
    let positions: [Int]
}

public func solutionFor(input: Input) -> Int {
    // possible optimization: group by unique positions with count but this already currently performs well enough

    let minimumPosition = input.positions.min()!
    let maximumPosition = input.positions.max()!

    var bestFuelCost = Int.max
    var bestPosition: Int = -1

    for alignPosition in minimumPosition ... maximumPosition {
        let fuelUsage = input.positions.reduce(0) { result, position in
            // triangular number: https://en.wikipedia.org/wiki/Triangular_number
            let delta = abs(position - alignPosition)

            return result + ((delta * (delta + 1)) >> 1)
        }

        print("Position: \(alignPosition) has cost \(fuelUsage)")

        if fuelUsage < bestFuelCost {
            bestFuelCost = fuelUsage
            bestPosition = alignPosition
        }
    }

    print("Best position: \(bestPosition)")
    
    return bestFuelCost
}
