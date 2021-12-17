import Foundation

public struct Input {
    let polymerTemplate: [Character]

    let insertionRules: [InsertionRule]

    let nrOfSteps = 40
}

public struct InsertionRule {
    let elements: [Character]
    let result: Character
}

struct Pair: Equatable, Hashable {
    let a: Character
    let b: Character
}

public func solutionFor(input: Input) -> Int {
    var currentPairs: [Pair: Int] = [:]
    var letterCount: [Character: Int] = [input.polymerTemplate[0]: 1]

    for characterIndex in 0 ..< input.polymerTemplate.count - 1 {
        let a = input.polymerTemplate[characterIndex]
        let b = input.polymerTemplate[characterIndex + 1]

        let pair = Pair(a: a, b: b)

        currentPairs[pair, default: 0] += 1

        letterCount[b, default: 0] += 1
    }

    let insertionRules: [Pair: [Pair]] = input.insertionRules.reduce(into: [Pair: [Pair]]()) { result, item in
        result[Pair(a: item.elements[0], b: item.elements[1])] = [
            Pair(a: item.elements[0], b: item.result),
            Pair(a: item.result, b: item.elements[1])
        ]
    }

    for stepIndex in 0 ..< input.nrOfSteps {
        print("Step \(stepIndex)")

        var newPairs: [Pair: Int] = [:]

        for (pair, count) in currentPairs {
            if let rulesNewPairs = insertionRules[pair] {
                for newPair in rulesNewPairs {
                    newPairs[newPair, default: 0] += count
                }

                letterCount[rulesNewPairs[0].b, default: 0] += count
            } else {
                newPairs[pair, default: 0] += count
            }
        }

        currentPairs = newPairs
    }

    let highestElementOccurence = letterCount.values.max()!
    let lowestElementOccurence = letterCount.values.min()!

    return highestElementOccurence - lowestElementOccurence
}
