import Foundation

public extension Array {
    @inlinable func count(_ isIncluded: (Element) throws -> Bool) rethrows -> Int {
        try filter(isIncluded).count
    }
	
	subscript(safe index: Int) -> Element? {
		guard index >= 0, index < endIndex else {
			return nil
		}

		return self[index]
	}
}

public extension ArraySlice where Iterator.Element: Hashable {
    var mostCommonElement: Element? {
        guard isNotEmpty else {
            return nil
        }

        let uniqueElements = Set<Element>(self)

        var mostCommonElement: Element?
        var maxCount: Int?

        for element in uniqueElements {
            let count = filter { $0 == element }.count

            if maxCount == nil || count > maxCount! {
                mostCommonElement = element
                maxCount = count
            }
        }

        return mostCommonElement!
    }

    var leastCommonElement: Element? {
        guard isNotEmpty else {
            return nil
        }

        let uniqueElements = Set<Element>(self)

        var leastCommonElement: Element?
        var maxCount: Int?

        for element in uniqueElements {
            let count = filter { $0 == element }.count

            if maxCount == nil || count < maxCount! {
                leastCommonElement = element
                maxCount = count
            }
        }

        return leastCommonElement!
    }
}

public extension Array where Iterator.Element: Hashable {
    var mostCommonElement: Element? {
        return ArraySlice(self).mostCommonElement
    }

    var leastCommonElement: Element? {
        return ArraySlice(self).leastCommonElement
    }
}

public extension [Bool] {
    mutating func negate() {
        for index in 0 ..< count {
            self[index] = !self[index]
        }
    }

    func negated() -> [Bool] {
        var newArray: [Bool] = Array(repeating: false, count: count)

        for index in 0 ..< count {
            newArray[index] = !self[index]
        }

        return newArray
    }
}

public extension ArraySlice where Element == Bool {
    mutating func negate() {
        for index in 0 ..< count {
            self[index] = !self[index]
        }
    }

    func negated() -> [Bool] {
        var newArray: [Bool] = Array(repeating: false, count: count)

        for index in 0 ..< count {
            newArray[index] = !self[index]
        }

        return newArray
    }
}
