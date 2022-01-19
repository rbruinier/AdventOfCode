import Foundation
import Tools

final class Day06Solver: DaySolver {
    let dayNumber: Int = 6

    private var input: Input!

    private struct Input {
        let groups: [Group]
    }

    private struct Group {
        let answers: [[String]]

        var uniqueAnswers: [String] {
            return Array(Set(answers.flatMap { $0 }))
        }

        var sharedAnswers: [String] {
            let uniqueAnswers = self.uniqueAnswers

            return uniqueAnswers.filter { uniqueAnswer in
                return answers.filter { $0.contains(uniqueAnswer) }.count == answers.count
            }
        }
    }

    func solvePart1() -> Any {
        return input.groups.reduce(0) { result, group in
            result + group.uniqueAnswers.count
        }
    }

    func solvePart2() -> Any {
        return input.groups.reduce(0) { result, group in
            result + group.sharedAnswers.count
        }
    }

    func parseInput(rawString: String) {
        let lines = rawString.allLines(includeEmpty: true)

        var groups: [Group] = []
        var groupAnswers: [[String]] = []

        for line in lines {
            if line.isEmpty {
                groups.append(.init(answers: groupAnswers))

                groupAnswers.removeAll()

                continue
            }

            groupAnswers.append(line.map { String($0) })
        }

        input = .init(groups: groups)
    }
}
