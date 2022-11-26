import Foundation
import MicroPNG
import Tools

print("Test")

let visualizer = Visualizer()

visualizer.fillRect(.init(origin: .init(x: 12, y: 102), size: .init(width: 96, height: 96)), color: .init(0xFFFF0000))
visualizer.fillRect(.init(origin: .init(x: 123, y: 123), size: .init(width: 94, height: 94)), color: .init(0xFF00FF00))
visualizer.fillRect(.init(origin: .init(x: 234, y: 144), size: .init(width: 92, height: 92)), color: .init(0xFF0000FF))

visualizer.drawRect(.init(origin: .init(x: 10, y: 100), size: .init(width: 100, height: 100)), width: 1, color: .init(0xFFFFFF00))
visualizer.drawRect(.init(origin: .init(x: 120, y: 120), size: .init(width: 100, height: 100)), width: 2, color: .init(0xFFFFFF00))
visualizer.drawRect(.init(origin: .init(x: 230, y: 140), size: .init(width: 100, height: 100)), width: 3, color: .init(0xFFFFFF00))

visualizer.drawText("123 test TEST", at: .init(x: 12, y: 102), color: .white)

let encoder = MicroPNG()

let pngData = try! encoder.encodeRGBUncompressed(data: visualizer.rawPixelData,
												 width: UInt32(visualizer.dimensions.width),
												 height: UInt32(visualizer.dimensions.height))

pngData.withUnsafeBytes { pointer in
	let data = Data(bytes: pointer.baseAddress!, count: pointer.count)

	try! data.write(to: URL(fileURLWithPath: "/Users/robert/Desktop/visualizer01.png"))
}
