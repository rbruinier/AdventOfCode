public enum Shoelace {
	public static func calculateArea(of coordinates: [Point2D]) -> Int {
		guard coordinates.count >= 3 else {
			preconditionFailure()
		}

		let area: Int = zip(coordinates, coordinates.dropFirst()).map {
			let c1 = $0.0
			let c2 = $0.1

			return c1.x * c2.y - c2.x * c1.y + abs(c2.x - c1.x) + abs(c2.y - c1.y)
		}.reduce(0, +)

		return area / 2 + 1
	}
}
