import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let rawLines = rawData
        .components(separatedBy: CharacterSet.newlines)
        .filter { $0.isEmpty == false }

    var entries: [Entry] = []

    for rawLine in rawLines {
        let lineComponents = rawLine.components(separatedBy: " | ")

        let uniqueDigitsInput = lineComponents[0].components(separatedBy: CharacterSet.whitespaces)
        let fourDigitOuput = lineComponents[1].components(separatedBy: CharacterSet.whitespaces)

        let uniqueDigits: [Digit] = uniqueDigitsInput.map { digits in
            Digit(segments: Set(digits.compactMap { Segment(rawValue: String($0)) }))
        }

        let outputDigits: [Digit] = fourDigitOuput.map { digits in
            Digit(segments: Set(digits.compactMap { Segment(rawValue: String($0)) }))
        }

        entries.append(.init(uniqueDigits: uniqueDigits, outputDigits: outputDigits))
    }

    return .init(entries: entries)
}
