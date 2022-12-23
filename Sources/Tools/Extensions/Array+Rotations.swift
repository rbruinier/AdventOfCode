extension RangeReplaceableCollection {
    func rotatingLeft(positions: Int) -> SubSequence {
        let index = index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex

        return self[index ..< endIndex] + self[startIndex ..< index]
    }

    func rotatingRight(positions: Int) -> SubSequence {
        let index = index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex

        return self[startIndex ..< index] + self[index ..< endIndex]
    }

    mutating func rotateLeft(positions: Int) {
        let index = index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex
        let slice = self[..<index]

        removeSubrange(..<index)

        insert(contentsOf: slice, at: endIndex)
    }

    mutating func rotateRight(positions: Int) {
        let index = index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex
        let slice = self[index ..< endIndex]

        removeSubrange(index ..< endIndex)

        insert(contentsOf: slice, at: startIndex)
    }
}
