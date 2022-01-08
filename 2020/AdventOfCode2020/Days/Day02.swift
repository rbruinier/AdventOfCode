import Foundation

final class Day02Solver: DaySolver {
    let dayNumber: Int = 2

    private var input: Input!

    private struct Input {
        let passwords: [Password]
    }

    private struct Password {
        var policyRange: ClosedRange<Int>
        var policyCharacter: String

        var password: String

        var isValidWithPolicy1: Bool {
            policyRange.contains(password.filter { String($0) == policyCharacter }.count)
        }

        var isValidWithPolicy2: Bool {
            let matchCount: Int = ((String(password[password.index(password.startIndex, offsetBy: policyRange.lowerBound - 1)]) == policyCharacter) ? 1 : 0)
                + ((String(password[password.index(password.startIndex, offsetBy: policyRange.upperBound - 1)]) == policyCharacter) ? 1 : 0)

            return matchCount == 1
        }
    }

    func solvePart1() -> Any {
        return input.passwords.filter { $0.isValidWithPolicy1 }.count
    }

    func solvePart2() -> Any {
        return input.passwords.filter { $0.isValidWithPolicy2 }.count
    }

    func parseInput(rawString: String) {
        let capturePattern = #"([0-9]*)-([0-9]*) ([a-z]*): ([a-z]*)"#
        let captureRegex = try! NSRegularExpression(pattern: capturePattern, options: [])

        let passwords: [Password] = rawString.allLines().compactMap { line in
            guard let match = captureRegex.matches(in: line, options: [], range: NSRange(line.startIndex ..< line.endIndex, in: line)).first else {
                return nil
            }

            let policyRangeLowerBounds = Int(line[Range(match.range(at: 1), in: line)!])!
            let policyRangeUpperBounds = Int(line[Range(match.range(at: 2), in: line)!])!
            let policyCharacter = String(line[Range(match.range(at: 3), in: line)!])
            let password = String(line[Range(match.range(at: 4), in: line)!])

            return .init(policyRange: (policyRangeLowerBounds ... policyRangeUpperBounds), policyCharacter: policyCharacter, password: password)
        }

        input = .init(passwords: passwords)
    }
}
