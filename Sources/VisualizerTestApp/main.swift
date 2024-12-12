import Foundation
import MicroPNG
import Tools

let visualizer = VisualizationContext()

visualizer.fillRect(.init(origin: .init(x: 12, y: 42), size: .init(width: 96, height: 96)), color: .init(0xFFFF_0000))
visualizer.fillRect(.init(origin: .init(x: 130, y: 70), size: .init(width: 80, height: 80)), color: .init(0xFF00_FF00))
visualizer.fillRect(.init(origin: .init(x: 234, y: 84), size: .init(width: 46, height: 45)), color: .bronze)
visualizer.fillRect(.init(origin: .init(x: 281, y: 84), size: .init(width: 45, height: 45)), color: .deepPink)
visualizer.fillRect(.init(origin: .init(x: 234, y: 130), size: .init(width: 46, height: 46)), color: .deepPink)
visualizer.fillRect(.init(origin: .init(x: 281, y: 130), size: .init(width: 45, height: 46)), color: .bronze)

visualizer.drawRect(.init(origin: .init(x: 10, y: 40), size: .init(width: 100, height: 100)), width: 1, color: .init(0xFFFF_FF00))
visualizer.drawRect(.init(origin: .init(x: 120, y: 60), size: .init(width: 100, height: 100)), width: 2, color: .init(0xFFFF_FF00))
visualizer.drawRect(.init(origin: .init(x: 230, y: 80), size: .init(width: 100, height: 100)), width: 3, color: .init(0xFFFF_FF00))

visualizer.drawText("Rectangles", at: .init(x: 170, y: 30), color: .white)

visualizer.drawLine(from: .init(x: 50, y: 200), to: .init(x: 230, y: 210), color: .white)
visualizer.drawLine(from: .init(x: 230, y: 210), to: .init(x: 190, y: 240), color: .white)
visualizer.drawLine(from: .init(x: 190, y: 240), to: .init(x: 180, y: 300), color: .white)
visualizer.drawLine(from: .init(x: 180, y: 300), to: .init(x: 50, y: 200), color: .white)

for radius in stride(from: 2, through: 10, by: 2) {
	visualizer.drawCircle(at: .init(x: 50, y: 200), radius: radius, color: .deepPink)
	visualizer.drawCircle(at: .init(x: 230, y: 210), radius: radius * 2, color: .deepPink)
	visualizer.drawCircle(at: .init(x: 190, y: 240), radius: radius * 3, color: .deepPink)
	visualizer.drawCircle(at: .init(x: 180, y: 300), radius: radius * 4, color: .deepPink)
}

visualizer.fillCircle(at: .init(x: 130, y: 230), radius: 17, color: .red)
visualizer.drawCircle(at: .init(x: 130, y: 230), radius: 17, color: .white)

visualizer.drawText("Lines & Circles", at: .init(x: 30, y: 270), color: .white)

visualizer.drawAALine(from: .init(x: 300, y: 200), to: .init(x: 390, y: 210), color: .white)
visualizer.drawAALine(from: .init(x: 390, y: 210), to: .init(x: 370, y: 290), color: .white)
visualizer.drawAALine(from: .init(x: 370, y: 290), to: .init(x: 300, y: 200), color: .white)

let encoder = MicroPNG()

let pngData = try! encoder.encodeRGBUncompressed(
	data: visualizer.rawPixelData,
	width: UInt32(visualizer.dimensions.width),
	height: UInt32(visualizer.dimensions.height)
)

let exportPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop/AdventOfCode/Test")

try! FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true)

pngData.withUnsafeBytes { pointer in
	let data = Data(bytes: pointer.baseAddress!, count: pointer.count)

	try! data.write(to: URL(fileURLWithPath: exportPath.appendingPathComponent("visualizer01.png").relativePath))
}
