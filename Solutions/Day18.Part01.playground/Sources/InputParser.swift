import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let rawLines: [[Character]] = rawData.components(separatedBy: CharacterSet.newlines).compactMap { $0.isEmpty == false ? $0 : nil }.map { $0.map { $0} }

    var lines: [Line] = []

    for rawLine in rawLines {
        let segments: [Segment] = rawLine.compactMap {
            switch String($0) {
            case "[":
                return .openBracket
            case "]":
                return .closeBracket
            case ",":
                return .comma
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                return .number(number: Int(String($0))!)
            default:
                return nil
            }
        }

        lines.append(.init(segments: segments))
    }

    return .init(lines: lines)
}
