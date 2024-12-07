import Foundation
import Tools

print("Examples 🎄")

extension DaySolver {
	var year: Int {
		0
	}
}

let days: [any DaySolver] = [
	GridExample(),
]

await solveDays(days, bundle: .module, customInputLoader: { day, bundle in
	guard let customFilename = day.customFilename else {
		fatalError()
	}
	
	let fileURL = bundle.url(forResource: customFilename, withExtension: "txt", subdirectory: "Input")!

	return try! String(contentsOf: fileURL)
})
