public struct Color {
	public let value: UInt32
	
	public static var black: Color { .init(0xFF000000) }

	public static var lightGray: Color { .init(0xFFD3D3D3) }
	public static var darkGray: Color { .init(0xFFA9A9A9) }
	public static var dimGray: Color { .init(0xFF696969) }
	public static var darkSlateGray: Color { .init(0xFF2F4F4F) }
	public static var slateGray: Color { .init(0xFF708090) }
	public static var lightSlateGray: Color { .init(0xFF778899) }

	public static var white: Color { .init(0xFFFFFFFF) }

	public static var red: Color { .init(0xFFFF0000) }

	public static var green: Color { .init(0xFF00FF00) }

	public static var blue: Color { .init(0xFF0000FF) }

	public static var copper: Color { .init(0xFFB87333) }
	public static var bronze: Color { .init(0xFFCD7F32) }
	public static var amber: Color { .init(0xFFFFBF00) }
	public static var desert: Color { .init(0xFFEDC9AF) }

	public static var orange: Color { .init(0xFFFFA500) }
	public static var darkOrange: Color { .init(0xFFFF8C00) }

	public static var pink: Color { .init(0xFFFFC0CB) }
	public static var hotPink: Color { .init(0xFFFF69B4) }
	public static var deepPink: Color { .init(0xFFFF1493) }

	public var a: UInt8 {
		UInt8(value >> 24)
	}

	public var r: UInt8 {
		UInt8((value >> 16) & 0xFF)
	}

	public var g: UInt8 {
		UInt8((value >> 8) & 0xFF)
	}

	public var b: UInt8 {
		UInt8(value & 0xFF)
	}

	public init(_ value: UInt32) {
		self.value = value
	}

	public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
		value = UInt32(a << 24) | UInt32(r << 16) | UInt32(g << 8) | UInt32(b)
	}
}
