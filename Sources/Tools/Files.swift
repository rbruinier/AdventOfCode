import Foundation

public func getRawInputStringFor(day: Int, year: Int, in bundle: Bundle) -> String {
	let fileURL = bundle.url(forResource: String(format: "Day%02d", day), withExtension: "txt", subdirectory: "\(year)/Inputs")!

	return try! String(contentsOf: fileURL, encoding: .utf8)
}

public func getRawExpectedResultsStringFor(day: Int, year: Int, in bundle: Bundle) -> String {
	let fileURL = bundle.url(forResource: String(format: "Day%02d", day), withExtension: "txt", subdirectory: "\(year)/ExpectedResults")!

	return try! String(contentsOf: fileURL, encoding: .utf8)
}
