import Foundation

public func getRawInputStringFor(day: Int, in bundle: Bundle) -> String {
	let fileURL = bundle.url(forResource: String(format: "Day%02d", day), withExtension: "txt", subdirectory: "Input")!

	return try! String(contentsOf: fileURL)
}
