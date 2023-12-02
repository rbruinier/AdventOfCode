import Foundation

public typealias AsciiCharacter = UInt8

public extension AsciiCharacter {
	init?(_ string: String) {
		guard let value = string.first?.asciiValue else {
			return nil
		}

		self = value
	}

	init?(_ character: String.Element) {
		guard let value = character.asciiValue else {
			return nil
		}

		self = value
	}

	func caseInsensitiveEqualTo(_ rhs: AsciiCharacter) -> Bool {
		upperCased == rhs.upperCased
	}

	var upperCased: AsciiCharacter {
		guard isLowerCase else {
			return self
		}

		return self - .a + .A
	}

	var isLowerCase: Bool {
		(.a ... .z).contains(self)
	}

	var isUpperCase: Bool {
		(.A ... .Z).contains(self)
	}
}

public struct AsciiString: Equatable, Hashable {
	fileprivate var characters: [AsciiCharacter]

	public var string: String {
		characters.map { String(Character(.init($0))) }.joined()
	}

	public init(string: String) {
		characters = string.map { $0.asciiValue! }
	}

	public init(_ slice: Slice<AsciiString>) {
		characters = Array(slice)
	}

	public init(_ characters: [AsciiCharacter]) {
		self.characters = characters
	}
}

public func + (_ lhs: AsciiString, _ rhs: AsciiString) -> AsciiString {
	AsciiString(lhs.characters + rhs.characters)
}

// MARK: - Collection

extension AsciiString: Collection {
	public typealias Index = Int
	public typealias Element = AsciiCharacter

	public var startIndex: Index { characters.startIndex }
	public var endIndex: Index { characters.endIndex }

	public subscript(index: Index) -> Iterator.Element { characters[index] }

	public func index(after i: Index) -> Index {
		characters.index(after: i)
	}

	public mutating func swapAt(_ i: Index, _ j: Index) {
		characters.swapAt(i, j)
	}

	public mutating func insert(_ newElement: AsciiCharacter, at index: Index) {
		characters.insert(newElement, at: index)
	}

	public mutating func remove(at index: Index) -> AsciiCharacter {
		characters.remove(at: index)
	}
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible

extension AsciiString: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		String(asciiString: self)
	}

	public var debugDescription: String {
		description
	}
}

public extension String {
	init(asciiString: AsciiString) {
		self = asciiString.string
	}
}
