import Foundation

public func getRawInputStringFor(day: Int, year: Int, in bundle: Bundle) -> String {
	let fileURL = bundle.url(forResource: String(format: "Day%02d", day), withExtension: "txt", subdirectory: "\(year)")!

	return try! String(contentsOf: fileURL)
}
