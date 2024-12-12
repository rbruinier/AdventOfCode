import Foundation

final class Font {
	private struct BitmapData: Decodable {
		let bitmaps: [String: [Int]]

		init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()

			bitmaps = try container.decode([String: [Int]].self)
		}
	}

	private var bitmapData: BitmapData!

	let characterSize: Size = .init(width: 5, height: 12)
	let verticalOffset = -3

	init() {
		let fileURL = Bundle.module.url(forResource: "monogram-bitmap", withExtension: "json", subdirectory: "Resources")!

		bitmapData = try! JSONDecoder().decode(BitmapData.self, from: Data(contentsOf: fileURL))
	}

	/// Parses character data and turns it into a 2D bitmap rows[columns[Bool]] where dimensions are characterSize and true/false means pixel on/off
	func dataFor(character: String) -> [[Bool]]? {
		guard let data = bitmapData.bitmaps[character] else {
			return [[]]
		}

		var result: [[Bool]] = []

		for y in 0 ..< characterSize.height {
			let rowData = data[y]

			var row: [Bool] = []
			for x in 0 ..< characterSize.width {
				row.append(((rowData >> x) & 1) == 1)
			}

			result.append(row)
		}

		return result
	}
}
