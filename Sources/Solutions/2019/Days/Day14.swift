import Foundation
import Tools

final class Day14Solver: DaySolver {
    let dayNumber: Int = 14

    private var input: Input!

    private struct Input {
        let reactions: [String: Reaction]
    }

    struct Reaction {
        let input: [String: Int]

        let outputQuantity: Int
        let outputChemical: String
    }

    private func make(chemical: String, minimumQuantity: Int, reactions: [String: Reaction], storage: inout [String: Int]) -> Int {
        let reaction = reactions[chemical]!
        let input = reaction.input

        let multiplier = Int(ceil(Double(minimumQuantity) / Double(reaction.outputQuantity)))

        var oreSum = 0
        for (chemical, quantity) in input {
            var remainingQuantity = quantity * multiplier

            if let storageQuantity = storage[chemical], storageQuantity > 0 {
                remainingQuantity = max(remainingQuantity - storageQuantity, 0)

                if remainingQuantity > 0 {
                    storage.removeValue(forKey: chemical)
                } else {
                    storage[chemical] = storageQuantity - (quantity * multiplier)
                }
            }

            if chemical == "ORE" {
                oreSum += remainingQuantity
            } else {
                if remainingQuantity > 0 {
                    oreSum += make(chemical: chemical, minimumQuantity: remainingQuantity, reactions: reactions, storage: &storage)
                }
            }
        }

        storage[chemical] = (reaction.outputQuantity * multiplier) - minimumQuantity

        return oreSum
    }

    func solvePart1() -> Any {
        var storage: [String: Int] = [:]

        let oreQuantity = make(chemical: "FUEL", minimumQuantity: 1, reactions: input.reactions, storage: &storage)

        return oreQuantity
    }

    func solvePart2() -> Any {
        var storage: [String: Int] = [:]

        // binary search
        var min = 0
        var max = 1_000_000_000_000

        while true {
            let fuelQuantity = min + ((max - min) / 2)

            let oreQuantity = make(chemical: "FUEL", minimumQuantity: fuelQuantity, reactions: input.reactions, storage: &storage)

            if oreQuantity >= 1_000_000_000_000 {
                max = fuelQuantity
            } else {
                min = fuelQuantity
            }

            if max - min <= 1 {
                return fuelQuantity
            }
        }
    }

    func parseInput(rawString: String) {
        let reactions: [String: Reaction] = Dictionary(uniqueKeysWithValues: rawString.allLines().map { line in
            let parts = line.components(separatedBy: " => ")

            let outputComponents = parts[1].components(separatedBy: " ")

            let outputQuantity = Int(outputComponents[0])!
            let outputChemical = outputComponents[1]

            let input: [String: Int] = Dictionary(uniqueKeysWithValues: parts[0].components(separatedBy: ", ").map { item in
                let inputComponents = item.components(separatedBy: " ")

                let quantity = Int(inputComponents[0])!
                let chemical = inputComponents[1]

                return (chemical, quantity)
            })

            return (outputChemical, Reaction(input: input, outputQuantity: outputQuantity, outputChemical: outputChemical))
        })

        input = .init(reactions: reactions)
    }
}
