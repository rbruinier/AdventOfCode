import Foundation

public struct Input {
    let octopi: [Octopus]

    let width: Int
    let height: Int

    let steps = 100
}

public struct Octopus {
    var energyLevel: Int
}

public func incrementAt(y: Int, x: Int, width: Int, height: Int, octopi: inout [Octopus]) {
    let level = octopi[(y * width) + x].energyLevel + 1

    if level <= 10 {
        octopi[(y * width) + x].energyLevel = level
    }

    guard level == 10 else {
        return
    }

    for innerY in max(y - 1, 0) ... min(y + 1, height - 1) {
        for innerX in max(x - 1, 0) ... min(x + 1, width - 1) {
            if innerY == y && innerX == x {
                continue
            }

            incrementAt(y: innerY, x: innerX, width: width, height: height, octopi: &octopi)
        }
    }
}

public func solutionFor(input: Input) -> Int {
    var octopi = input.octopi

    var totalNumberOfFlashes = 0

    for step in 0 ..< input.steps {
        // phase 1 is incrementing
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                incrementAt(y: y, x: x, width: input.width, height: input.height, octopi: &octopi)
            }
        }

        var numberOfFlashes = 0

        // phase 2 is flashing and resetting
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                if octopi[(y * input.width) + x].energyLevel >= 10 {
                    numberOfFlashes += 1

                    octopi[(y * input.width) + x].energyLevel = 0
                }
            }
        }

        print("\(step); number of flashes: \(numberOfFlashes)")

        for y in 0 ..< input.height {
            var debugString = ""

            for x in 0 ..< input.width {
                debugString += String(octopi[y * input.width + x].energyLevel)
            }

            print(debugString)
        }

        totalNumberOfFlashes += numberOfFlashes
    }

    return totalNumberOfFlashes
}
