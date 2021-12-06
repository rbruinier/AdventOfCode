import Foundation

public struct Input {
    let initialTimers: [Int]
    let days: Int = 256
}

public struct AgeGroup {
    var nrOfFish: Int = 0
}

public func solutionFor(input: Input) -> Int {
    var ageGroups: [AgeGroup] = Array(repeating: .init(), count: 9)

    for input in input.initialTimers {
        ageGroups[input].nrOfFish += 1
    }

    for _ in 0 ..< input.days {
        var newAgeGroups: [AgeGroup] = Array(repeating: .init(), count: 9)

        for age in stride(from: 8, through: 0, by: -1) {
            if age >= 1 {
                newAgeGroups[age - 1].nrOfFish = ageGroups[age].nrOfFish
            } else {
                newAgeGroups[8].nrOfFish = ageGroups[0].nrOfFish
                newAgeGroups[6].nrOfFish += ageGroups[0].nrOfFish
            }
        }

        ageGroups = newAgeGroups
    }

    return ageGroups.reduce(0) { result, group in
        result + group.nrOfFish
    }
}
