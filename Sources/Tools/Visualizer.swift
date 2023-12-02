import Foundation

public protocol Visualizer {
	var solver: any DaySolver { get }

	var dimensions: Size { get }

	var title: String { get }
	var frameDescription: String? { get }

	var isCompleted: Bool { get }

	func renderFrame(with context: VisualizationContext)
}

public extension Visualizer {
	var title: String {
		"AoC Day \(solver.dayNumber) of \(solver.year)"
	}
}

public func visualize(solver: any DaySolver, rootPath: URL) {
	let year = solver.year
	let day = solver.dayNumber

	let exportPath = rootPath.appendingPathComponent("\(year)/\(day)")

	try? FileManager.default.removeItem(at: exportPath)
	try! FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true)

	let visualizer = solver.createVisualizer()!

	let context = VisualizationContext(dimensions: visualizer.dimensions)

	while visualizer.isCompleted == false {
		visualizer.renderFrame(with: context)

		context.drawCenteredText(visualizer.title, atY: 4, color: .white)

		if let frameDescription = visualizer.frameDescription {
			context.drawCenteredText(frameDescription, atY: visualizer.dimensions.height - 10, color: .white)
		}

		context.exportFrameToPNG(rootPath: exportPath.relativePath, exportScale: 1)
	}
}
