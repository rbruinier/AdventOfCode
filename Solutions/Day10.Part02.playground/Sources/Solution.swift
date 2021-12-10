import Foundation

public struct Input {
    let lines: [[Character]]
}

enum Validation: Equatable {
    case valid
    case incomplete(remainingStack: [Character])
    case corrupted(wrongCharacter: Character)
}

func validateLine(_ line: [Character]) -> Validation {
    var stack: [Character] = []

    for character in line {
        switch character {
        case "(", "[", "{", "<":
            stack.append(character)
        case ")", "]", "}", ">":
            let matching: Bool

            switch character {
            case ")": matching = stack.last == "("
            case "]": matching = stack.last == "["
            case "}": matching = stack.last == "{"
            case ">": matching = stack.last == "<"
            default: fatalError("Invalid charachter")
            }

            if matching == false {
                return .corrupted(wrongCharacter: character)
            }

            stack.removeLast()
        default:
            fatalError("Unknown character: \(character)")
        }
    }

    return stack.isEmpty ? .valid : .incomplete(remainingStack: stack)
}

public func solutionFor(input: Input) -> Int {
    let validations: [Validation] = input.lines.map(validateLine)

    let scores: [Int] = validations.compactMap { validation in
        switch validation {
        case .incomplete(let remainingStack):
            return remainingStack.reversed().reduce(0) { result, character in
                let score: Int

                switch character {
                    case "(": score = 1
                    case "[": score = 2
                    case "{": score = 3
                    case "<": score = 4
                    default: fatalError("Unexpected character")
                }

                return (result! * 5) + score
            }
        default:
            return nil
        }
    }

    return scores.sorted()[scores.count >> 1]
}
