import Foundation

public struct Input {
    let lines: [[Character]]
}

enum Validation {
    case valid
    case incomplete
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

    return stack.isEmpty ? .valid : .incomplete
}

public func solutionFor(input: Input) -> Int {
    let validations: [Validation] = input.lines.map(validateLine)

    let score = validations.reduce(0) { result, validation in
        switch validation {
        case .corrupted(let wrongCharacter):
            switch wrongCharacter {
            case ")": return result + 3
            case "]": return result + 57
            case "}": return result + 1197
            case ">": return result + 25137
            default: fatalError("Unexpected character")
            }
        default:
            return result
        }
    }
    
    return score
}
