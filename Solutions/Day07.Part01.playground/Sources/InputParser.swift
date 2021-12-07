import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let rawNumbers = rawData
        .components(separatedBy: ",")
        .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
        .compactMap { Int($0) }

    return .init(positions: rawNumbers)
}
