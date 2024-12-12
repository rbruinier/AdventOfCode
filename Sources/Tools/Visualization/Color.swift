public struct Color {
	public let value: UInt32

	public static var black: Color { .init(0xFF00_0000) }

	public static var lightGray: Color { .init(0xFFD3_D3D3) }
	public static var darkGray: Color { .init(0xFFA9_A9A9) }
	public static var dimGray: Color { .init(0xFF69_6969) }
	public static var darkSlateGray: Color { .init(0xFF2F_4F4F) }
	public static var slateGray: Color { .init(0xFF70_8090) }
	public static var lightSlateGray: Color { .init(0xFF77_8899) }

	public static var white: Color { .init(0xFFFF_FFFF) }

	public static var red: Color { .init(0xFFFF_0000) }

	public static var green: Color { .init(0xFF00_FF00) }

	public static var blue: Color { .init(0xFF00_00FF) }

	public static var copper: Color { .init(0xFFB8_7333) }
	public static var bronze: Color { .init(0xFFCD_7F32) }
	public static var amber: Color { .init(0xFFFF_BF00) }
	public static var desert: Color { .init(0xFFED_C9AF) }

	public static var orange: Color { .init(0xFFFF_A500) }
	public static var darkOrange: Color { .init(0xFFFF_8C00) }

	public static var pink: Color { .init(0xFFFF_C0CB) }
	public static var hotPink: Color { .init(0xFFFF_69B4) }
	public static var deepPink: Color { .init(0xFFFF_1493) }

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
		value = UInt32(a) << 24 | UInt32(r) << 16 | UInt32(g) << 8 | UInt32(b)
	}

	// factor runs from 0 ... 255 where 0 means 0% of self and 255 means 100% self
	public func faded(factor: Int) -> Color {
		Color(
			r: UInt8((Int(r) * factor) >> 8),
			g: UInt8((Int(g) * factor) >> 8),
			b: UInt8((Int(b) * factor) >> 8)
		)
	}

	// factor runs from 0 ... 255 where 0 means 100% self and 255 means 0% self
	public func mixed(with rhs: Color, factor: Int) -> Color {
		let inverseFactor = 255 - factor

		return Color(
			r: UInt8((Int(r) * inverseFactor) >> 8) + UInt8((Int(rhs.r) * factor) >> 8),
			g: UInt8((Int(g) * inverseFactor) >> 8) + UInt8((Int(rhs.g) * factor) >> 8),
			b: UInt8((Int(b) * inverseFactor) >> 8) + UInt8((Int(rhs.b) * factor) >> 8)
		)
	}
}
