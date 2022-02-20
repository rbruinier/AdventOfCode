import Foundation

extension String {
    public var uniqueCharacters: [String] {
        var result: Set<String> = []

        for character in self {
            result.insert(String(character))
        }

        return Array(result)
    }
}
