import Foundation
import MicroPNG

public final class VisualizationContext {
	public let dimensions: Size
	public let frameRect: Rect

	private var frame: Frame

	public private(set) var frameCounter = 0
	private var firstFrame = true

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

		if firstFrame == false {
			frameCounter += 1
		}

		firstFrame = false
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
		6 * text.count
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

	public func drawCircle(at point: Point2D, radius: Int, color: Color) {
		var x = 0
		var y = radius
		var d = 3 - (2 * radius)

		while y >= x {
			let drawingPoints: [Point2D] = [
				.init(x: point.x + x, y: point.y + y),
				.init(x: point.x - x, y: point.y + y),
				.init(x: point.x + x, y: point.y - y),
				.init(x: point.x - x, y: point.y - y),
				.init(x: point.x + y, y: point.y + x),
				.init(x: point.x - y, y: point.y + x),
				.init(x: point.x + y, y: point.y - x),
				.init(x: point.x - y, y: point.y - x),
			]

			for drawingPoint in drawingPoints where frameRect.contains(point: drawingPoint) {
				frame.data[drawingPoint.y * dimensions.width + drawingPoint.x] = color.value
			}

			x += 1

			if d < 0 {
				d = d + (4 * x) + 6
			} else {
				d = d + 4 * (x - y) + 10

				y -= 1
			}
		}
	}

	public func fillCircle(at point: Point2D, radius: Int, color: Color) {
		var x = 0
		var y = radius
		var d = 3 - (2 * radius)

		var lineStartX: [Int: Int] = [:]
		var lineEndX: [Int: Int] = [:]

		while y >= x {
			let drawingPoints: [Point2D] = [
				.init(x: point.x + x, y: point.y + y),
				.init(x: point.x - x, y: point.y + y),
				.init(x: point.x + x, y: point.y - y),
				.init(x: point.x - x, y: point.y - y),
				.init(x: point.x + y, y: point.y + x),
				.init(x: point.x - y, y: point.y + x),
				.init(x: point.x + y, y: point.y - x),
				.init(x: point.x - y, y: point.y - x),
			]

			for drawingPoint in drawingPoints {
				lineStartX[drawingPoint.y] = min(lineStartX[drawingPoint.y, default: Int.max], drawingPoint.x)
				lineEndX[drawingPoint.y] = max(lineEndX[drawingPoint.y, default: Int.min], drawingPoint.x)
			}

			x += 1

			if d < 0 {
				d = d + (4 * x) + 6
			} else {
				d = d + 4 * (x - y) + 10

				y -= 1
			}
		}

		guard let minY = lineStartX.keys.min(), let maxY = lineStartX.keys.max() else {
			return
		}

		for y in minY ... maxY {
			let startX = lineStartX[y]!
			let endX = lineEndX[y]!

			var index = y * dimensions.width + startX

			for x in startX ... endX where frameRect.contains(point: .init(x: x, y: y)) {
				frame.data[index] = color.value

				index += 1
			}
		}
	}

	public func drawLine(from pointA: Point2D, to pointB: Point2D, color: Color) {
		let deltaX = Double(pointB.x) - Double(pointA.x)
		let deltaY = Double(pointB.y) - Double(pointA.y)

		if abs(deltaX) > abs(deltaY) {
			let startPoint: Point2D
			let endPoint: Point2D

			if deltaX >= 0 {
				startPoint = pointA
				endPoint = pointB
			} else {
				startPoint = pointB
				endPoint = pointA
			}

			let stepY = deltaY / deltaX
			var currentY = Double(startPoint.y)

			for x in startPoint.x ..< endPoint.x {
				let y = Int(currentY)

				if frameRect.contains(point: .init(x: x, y: y)) {
					frame.data[y * dimensions.width + x] = color.value
				}

				currentY += stepY
			}
		} else {
			let startPoint: Point2D
			let endPoint: Point2D

			if deltaY >= 0 {
				startPoint = pointA
				endPoint = pointB
			} else {
				startPoint = pointB
				endPoint = pointA
			}

			let stepX = deltaX / deltaY
			var currentX = Double(startPoint.x)

			for y in startPoint.y ..< endPoint.y {
				let x = Int(currentX)

				if frameRect.contains(point: .init(x: x, y: y)) {
					frame.data[y * dimensions.width + x] = color.value
				}

				currentX += stepX
			}
		}
	}

	public func drawAALine(from pointA: Vector2, to pointB: Vector2, color: Color) {
		let deltaX = pointB.x - pointA.x
		let deltaY = pointB.y - pointA.y

		let startPoint: Vector2
		let endPoint: Vector2

		if abs(deltaX) > abs(deltaY) {
			if deltaX >= 0 {
				startPoint = pointA
				endPoint = pointB
			} else {
				startPoint = pointB
				endPoint = pointA
			}

			let stepY = deltaY / deltaX
			var currentY = Double(startPoint.y)

			for x in Int(floor(startPoint.x)) ..< Int(floor(endPoint.x)) {
				let y1 = Int(floor(currentY))
				let y2 = y1 + 1

				let fade1 = Int((currentY - Double(y1)) * 255.0)
				let fade2 = 255 - fade1

				if frameRect.contains(point: .init(x: x, y: y1)) {
					frame.data[y1 * dimensions.width + x] = color.mixed(with: Color(frame.data[y1 * dimensions.width + x]), factor: fade1).value
				}

				if frameRect.contains(point: .init(x: x, y: y2)) {
					frame.data[y2 * dimensions.width + x] = color.mixed(with: Color(frame.data[y2 * dimensions.width + x]), factor: fade2).value
				}

				currentY += stepY
			}
		} else {
			if deltaY >= 0 {
				startPoint = pointA
				endPoint = pointB
			} else {
				startPoint = pointB
				endPoint = pointA
			}

			let stepX = deltaX / deltaY
			var currentX = Double(startPoint.x)

			for y in Int(floor(startPoint.y)) ..< Int(floor(endPoint.y)) {
				let x1 = Int(floor(currentX))
				let x2 = x1 + 1

				let fade1 = Int((currentX - Double(x1)) * 255.0)
				let fade2 = 255 - fade1

				if frameRect.contains(point: .init(x: x1, y: y)) {
					frame.data[y * dimensions.width + x1] = color.mixed(with: Color(frame.data[y * dimensions.width + x1]), factor: fade1).value
				}

				if frameRect.contains(point: .init(x: x2, y: y)) {
					frame.data[y * dimensions.width + x2] = color.mixed(with: Color(frame.data[y * dimensions.width + x2]), factor: fade2).value
				}

				currentX += stepX
			}
		}
	}

	public func exportFrameToPNG(rootPath: String, exportScale: Int = 1) {
		var scaledFrameData: [UInt32] = frame.data
		var scaledDimensions = dimensions

		if exportScale > 1 {
			scaledDimensions = .init(width: dimensions.width * exportScale, height: dimensions.height * exportScale)

			scaledFrameData = Array(repeating: 0, count: scaledDimensions.width * scaledDimensions.height)

			var index = 0
			for y in 0 ..< scaledDimensions.height {
				for x in 0 ..< scaledDimensions.width {
					let originalY = y / exportScale
					let originalX = x / exportScale

					scaledFrameData[index] = frame.data[originalY * dimensions.width + originalX]

					index += 1
				}
			}
		}

		let pngData = try! pngEncoder.encodeRGBUncompressed(
			data: scaledFrameData,
			width: UInt32(scaledDimensions.width),
			height: UInt32(scaledDimensions.height)
		)

		let imageFilename = String(format: "%04d.png", frameCounter)

		pngData.withUnsafeBytes { pointer in
			let data = Data(bytes: pointer.baseAddress!, count: pointer.count)

			try! data.write(to: URL(fileURLWithPath: rootPath + "/" + imageFilename))
		}
	}
}
