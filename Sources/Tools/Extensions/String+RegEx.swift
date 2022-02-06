import Foundation

extension String {
    public func getCapturedValues(pattern: String) -> [String]? {
        let captureRegex = try! NSRegularExpression(pattern: pattern, options: [])

        guard let match = captureRegex.matches(in: self, options: [], range: NSRange(self.startIndex ..< self.endIndex, in: self)).first else {
            return nil
        }
        
        return (1 ..< match.numberOfRanges).map { index in
            String(self[Range(match.range(at: index), in: self)!])
        }
    }
}
