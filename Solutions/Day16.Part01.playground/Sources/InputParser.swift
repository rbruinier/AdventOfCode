import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let rawLine = rawData
        .components(separatedBy: CharacterSet.whitespacesAndNewlines)
        .first!

    return .init(hexString: rawLine)
}
