import Foundation

extension ArraySlice where Iterator.Element: Hashable {
    public var mostCommonElement: Element? {
        guard self.isNotEmpty else {
            return nil
        }

        let uniqueElements = Set<Element>(self)

        var mostCommonElement: Element? = nil
        var maxCount: Int? = nil

        for element in uniqueElements {
            let count = self.filter { $0 == element }.count

            if maxCount == nil || count > maxCount! {
                mostCommonElement = element
                maxCount = count
            }
        }

        return mostCommonElement!
    }

    public var leastCommonElement: Element? {
        guard self.isNotEmpty else {
            return nil
        }

        let uniqueElements = Set<Element>(self)

        var leastCommonElement: Element? = nil
        var maxCount: Int? = nil

        for element in uniqueElements {
            let count = self.filter { $0 == element }.count

            if maxCount == nil || count < maxCount! {
                leastCommonElement = element
                maxCount = count
            }
        }

        return leastCommonElement!
    }
}

extension Array where Iterator.Element: Hashable {
    public var mostCommonElement: Element? {
        return ArraySlice(self).mostCommonElement
    }

    public var leastCommonElement: Element? {
        return ArraySlice(self).leastCommonElement
    }
}
