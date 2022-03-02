import Foundation

public struct AsciiString {
    private var characters: [UInt8]
    
    public var string: String {
        characters.map { String(Character(.init($0))) }.joined()
    }
    
    public init(string: String) {
        characters = string.map { $0.asciiValue! }
    }
    
    public init(_ slice: Slice<AsciiString>) {
        characters = Array(slice)
    }
}

extension AsciiString: Collection {
    public typealias Index = Int
    public typealias Element = UInt8

    public var startIndex: Index { return characters.startIndex }
    public var endIndex: Index { return characters.endIndex }
        
    public subscript(index: Index) -> Iterator.Element {
        get { return characters[index] }
    }

    public func index(after i: Index) -> Index {
        return characters.index(after: i)
    }
}

extension String {
    public init(asciiString: AsciiString) {
        self = asciiString.string
    }
}
