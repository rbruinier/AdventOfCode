import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let rawLines = rawData
        .components(separatedBy: CharacterSet.newlines)
        .filter { $0.isEmpty == false }

    let lines = rawLines.map { [Character]($0) }

    return .init(lines: lines)
}
