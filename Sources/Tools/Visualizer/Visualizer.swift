import Foundation
import MicroPNG

public final class Visualizer {
	public let dimensions: Size
	public let frameRect: Rect

	private var frame: Frame

	public private(set) var frameCounter = 0

	private let font: Font

	private let pngEncoder = MicroPNG()

	public var rawPixelData: [UInt32] {
		let data = frame.data

		return data
	}

	public init(dimensions: Size = .init(width: 512, height: 512)) {
		self.dimensions = dimensions
		frameRect = Rect(origin: .zero, size: dimensions)

		frame = Frame(dimensions: dimensions)

		font = Font()
	}

	public func startNewFrame(clearCanvas: Bool = true) {
		if clearCanvas {
			frame = Frame(dimensions: dimensions)
		}

		frameCounter += 1
	}

	public func fillRect(_ rect: Rect, color: Color) {
		let clippedRect = rect.clippedWith(rect: frameRect)

		guard clippedRect != .zero else {
			return
		}

		for y in clippedRect.topLeft.y ..< clippedRect.bottomRight.y {
			var index = (y * dimensions.width) + clippedRect.origin.x

			for _ in clippedRect.topLeft.x ..< clippedRect.bottomRight.x {
				frame.data[index] = color.value

				index += 1
			}
		}
	}

	public func drawRect(_ rect: Rect, width: Int, color: Color) {
		guard width > 0 else {
			return
		}

		// 4 rects
		fillRect(.init(origin: rect.origin, size: .init(width: rect.size.width, height: width)), color: color)
		fillRect(.init(origin: rect.origin + Point2D(x: 0, y: rect.size.height - width), size: .init(width: rect.size.width, height: width)), color: color)
		fillRect(.init(origin: rect.origin, size: .init(width: width, height: rect.size.height)), color: color)
		fillRect(.init(origin: rect.origin + Point2D(x: rect.size.width - width, y: 0), size: .init(width: width, height: rect.size.height)), color: color)
	}

	public func widthOfText(_ text: String) -> Int {
		return 6 * text.count
	}
	
	public func drawText(_ text: String, at origin: Point2D, color: Color) {
		for (characterIndex, character) in text.enumerated() {
			guard let data = font.dataFor(character: String(character)) else {
				continue
			}

			for (rowIndex, row) in data.enumerated() {
				for (columnIndex, column) in row.enumerated() where column == true {
					let drawPoint = Point2D(
						x: origin.x + characterIndex * 6 + columnIndex,
						y: origin.y + rowIndex + font.verticalOffset
					)

					guard frameRect.contains(point: drawPoint) else {
						continue
					}

					frame.data[drawPoint.y * dimensions.width + drawPoint.x] = color.value
				}
			}
		}
	}

	public func drawCenteredText(_ text: String, atY y: Int, color: Color) {
		let widthOfText = widthOfText(text)
		
		drawText(text, at: .init(x: (dimensions.width - widthOfText) / 2, y: y), color: .white)
	}

	public func exportFrameToPNG(rootPath: String) {
		let pngData = try! pngEncoder.encodeRGBUncompressed(
			data: frame.data,
			width: UInt32(dimensions.width),
			height: UInt32(dimensions.height)
		)

		let imageFilename = String(format: "%04d.png", frameCounter)

		pngData.withUnsafeBytes { pointer in
			let data = Data(bytes: pointer.baseAddress!, count: pointer.count)

			try! data.write(to: URL(fileURLWithPath: rootPath + "/" + imageFilename))
		}
	}
}
