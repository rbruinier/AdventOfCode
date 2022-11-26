public enum VisualizableResult {
	case ready
	case finished
}

public protocol Visualizable {
	func createVisualizer() -> Visualizer
	func visualizeState(with visualizer: Visualizer) -> VisualizableResult
}
