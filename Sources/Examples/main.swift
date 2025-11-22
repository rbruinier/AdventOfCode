import Foundation
import Tools

print("Examples 🎄")

func customLoader(day: any DaySolver, bundle: Bundle) -> String {
	guard let customFilename = day.customFilename else {
		fatalError()
	}

	let fileURL = bundle.url(forResource: customFilename, withExtension: "txt", subdirectory: "Input")!

	return try! String(contentsOf: fileURL, encoding: .utf8)
}

import Foundation
import Tools

var yearSolver = YearSolver(year: 2025)

yearSolver.addSolver(GridExample(), customInputReader: customLoader)
yearSolver.addSolver(ShortestPathInGridExample(), customInputReader: customLoader)

await solveYear(yearSolver, dayNumber: nil, bundle: .module)
