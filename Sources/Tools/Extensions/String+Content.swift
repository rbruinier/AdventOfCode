import Foundation

extension String {
    public var uniqueCharacters: [String] {
        var result: Set<String> = []

        for character in self {
            result.insert(String(character))
        }

        return Array(result)
    }

    public var asAsciiArray: [UInt8] {
        return self.map { $0.asciiValue! }
    }
}
