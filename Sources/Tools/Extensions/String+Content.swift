import Foundation

extension String {
    public var asAsciiArray: [UInt8] {
        return self.map { $0.asciiValue! }
    }
}
