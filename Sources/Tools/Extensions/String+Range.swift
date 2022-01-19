import Foundation

extension String {
    public subscript(range: Range<Int>) -> String {
        return String(self[index(startIndex, offsetBy: range.lowerBound) ..< index(startIndex, offsetBy: range.upperBound)])
    }


    public subscript(range: ClosedRange<Int>) -> String {
        return String(self[index(startIndex, offsetBy: range.lowerBound) ... index(startIndex, offsetBy: range.upperBound)])
    }
}
