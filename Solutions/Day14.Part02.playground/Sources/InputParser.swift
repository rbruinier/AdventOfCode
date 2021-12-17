import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let rawLines = rawData
        .components(separatedBy: CharacterSet.newlines)
        .compactMap { $0.isEmpty == false ? $0 : nil }

    let polymerTemplate = rawLines[0].map { $0 }

    var rules: [InsertionRule] = []

    for index in 1 ..< rawLines.count {
        let rawLine = rawLines[index]

        let components = rawLine.description.components(separatedBy: " -> ")

        let elements = components[0].map { $0 }
        let result = components[1].first!

        rules.append(InsertionRule(elements: elements, result: result))
    }

    return .init(polymerTemplate: polymerTemplate, insertionRules: rules)
}
