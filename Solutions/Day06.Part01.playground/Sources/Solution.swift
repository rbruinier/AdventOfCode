import Foundation

public struct Input {
    let initialTimers: [Int]
    let days: Int = 80
}

public func solutionFor(input: Input) -> Int {
    var fish: [Fish] = input.initialTimers.map(Fish.init(counter:))

    for _ in 0 ..< input.days {
        var newFish: [Fish] = []

        for fishIndex in 0 ..< fish.count {
            let spawnNewFish = fish[fishIndex].age()

            if spawnNewFish {
                newFish.append(Fish(counter: 8))
            }
        }

        fish.append(contentsOf: newFish)
    }

    return fish.count
}

struct Fish {
    var counter: Int

    mutating func age() -> Bool {
        counter -= 1

        if counter == -1 {
            counter = 6

            return true
        }

        return false
    }
}
