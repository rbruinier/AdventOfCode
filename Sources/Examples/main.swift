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
	ShortestPathInGridExample()
]

func customLoader(day: any DaySolver, bundle: Bundle) -> String {
	guard let customFilename = day.customFilename else {
		fatalError()
	}

	let fileURL = bundle.url(forResource: customFilename, withExtension: "txt", subdirectory: "Input")!

	return try! String(contentsOf: fileURL)
}

await solveDays(days, bundle: .module, customInputLoader: customLoader)
