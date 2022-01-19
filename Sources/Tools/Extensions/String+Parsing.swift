import Foundation

extension String {
    public func allLines(includeEmpty: Bool = false) -> [String] {
        var lines = components(separatedBy: .newlines)

        if includeEmpty == false {
            lines = lines.filter { $0.isNotEmpty }
        }

        return lines
    }

    public func parseCommaSeparatedInts(filterInvalid: Bool = true) -> [Int] {
        let items = components(separatedBy: ",")

        if filterInvalid {
            return items.compactMap { Int(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
        } else {
            return items.map { Int(String($0))! }
        }
    }
}
