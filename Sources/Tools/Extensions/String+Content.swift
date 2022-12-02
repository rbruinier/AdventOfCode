import Foundation

public extension String {
    var asAsciiArray: [UInt8] {
        return map { $0.asciiValue! }
    }
}
