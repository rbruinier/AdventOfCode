import Foundation

extension String {
    func allLines(includeEmpty: Bool = false) -> [String] {
        var lines = components(separatedBy: .newlines)

        if includeEmpty == false {
            lines = lines.filter { $0.isNotEmpty }
        }

        return lines
    }

    func parseCommaSeparatedInts(filterInvalid: Bool = true) -> [Int] {
        let items = components(separatedBy: ",")

        if filterInvalid {
            return items.compactMap { Int(String($0)) }
        } else {
            return items.map { Int(String($0))! }
        }
    }
}
