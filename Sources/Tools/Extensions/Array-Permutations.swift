import Foundation

extension Array {
    /**
     Returns all permutations of an array.

     See: https://en.wikipedia.org/wiki/Heap%27s_algorithm
     */
    public var permutations: [[Element]] {
        var stack = [Int](repeating: 0, count: self.count)

        var items = self
        var permutations: [[Element]] = [self]

        var i = 0
        while i < self.count {
            if stack[i] < i {
                if i & 1 == 0 {
                    items.swapAt(0, i)
                } else {
                    items.swapAt(stack[i], i)
                }

                permutations.append(items)

                stack[i] += 1
                i = 0
            } else {
                stack[i] = 0
                i += 1
            }
        }

        return permutations
    }

    public func subsets(minLength: Int, maxLength: Int) -> [[Element]] {
        var subsets: [[Element]] = []

        for length in minLength ... maxLength {
            if length == 0 {
                subsets.append([])
            } else if length == 1 {
                subsets.append(contentsOf: self.map { [$0] })
            } else if length == 2 {
                for startIndex in 0 ..< self.count - length {
                    for item in self[startIndex + 1 ..< self.count] {
                        subsets.append([self[startIndex], item])
                    }
                }
            } else {
                fatalError("Not yet implemented")
            }
        }

        return subsets
    }
}
