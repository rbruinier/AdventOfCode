struct Frame {
	let dimensions: Size
	var data: [UInt32]

	init(dimensions: Size) {
		self.dimensions = dimensions

		data = Array(repeating: 0, count: dimensions.width * dimensions.height)
	}
}
