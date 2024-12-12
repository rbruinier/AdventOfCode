public extension Collection<UInt8> {
	@inline(__always)
	var asNibbles: [UInt8] {
		var result = [UInt8](repeating: 0, count: count * 2)

		var nibbleIndex = 0
		for byte in self {
			result[nibbleIndex] = byte >> 4

			nibbleIndex += 1

			result[nibbleIndex] = byte & 0xF

			nibbleIndex += 1
		}

		return result
	}

	@inline(__always)
	var bytesAsHexAscii: [UInt8] {
		var result = [UInt8](repeating: 0, count: count * 2)

		var index = 0
		for byte in self {
			let highByte = byte >> 4
			let lowByte = byte & 0xF

			if highByte <= 9 {
				result[index] = highByte + 48 // 0 ... 9
			} else {
				result[index] = highByte + 87 // a ... f
			}

			index += 1

			if lowByte <= 9 {
				result[index] = lowByte + 48 // 0 ... 9
			} else {
				result[index] = lowByte + 87 // a ... f
			}

			index += 1
		}

		return result
	}
}
