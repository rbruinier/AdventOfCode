import Foundation

public extension String {
	var asAsciiArray: [UInt8] {
		map { $0.asciiValue! }
	}
}
