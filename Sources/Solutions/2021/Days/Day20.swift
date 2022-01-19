import Foundation
import Tools

final class Day20Solver: DaySolver {
    let dayNumber: Int = 20

    private var input: Input!

    private struct Input {
        let enhancementMapping: [Int]
        let bitmap: Bitmap

        let nrOfSteps = 50
    }

    private struct Bitmap: CustomStringConvertible {
        var pixels: [Int]

        let width: Int
        let height: Int

        init(pixels: [Int], width: Int, height: Int) {
            self.pixels = pixels
            self.width = width
            self.height = height
        }

        init(width: Int, height: Int) {
            self.width = width
            self.height = height

            pixels = Array(repeating: 0, count: width * height)
        }

        subscript(row: Int, column: Int, default default: Int = 0) -> Int {
            get {
                guard (0 ..< height).contains(row) && (0 ..< width).contains(column) else {
                    return `default`
                }

                return pixels[row * width + column]
            }
            set {
                pixels[row * width + column] = newValue
            }
        }

        var description: String {
            var result = "width: \(width)\nheight: \(height)\n"

            var index = 0
            for _ in 0 ..< height {
                for _ in 0 ..< width {
                    result += pixels[index] == 1 ? "#" : "."

                    index += 1
                }

                result += "\n"
            }

            return result
        }
    }

    private func solve(steps: Int) -> Int {
        var originalBitmap = input.bitmap

        for stepIndex in 0 ..< steps {
            var targetBitmap = Bitmap(width: originalBitmap.width + 2, height: originalBitmap.height + 2)

            for y in 0 ..< targetBitmap.height {
                for x in 0 ..< targetBitmap.width {
                    let originalY = y - 1
                    let originalX = x - 1

                    let defaultValue = ((stepIndex & 1) == 1) ? 1 : 0

                    let pixels: [Int] = [
                        originalBitmap[originalY - 1, originalX - 1, default: defaultValue],
                        originalBitmap[originalY - 1, originalX + 0, default: defaultValue],
                        originalBitmap[originalY - 1, originalX + 1, default: defaultValue],
                        originalBitmap[originalY + 0, originalX - 1, default: defaultValue],
                        originalBitmap[originalY + 0, originalX + 0, default: defaultValue],
                        originalBitmap[originalY + 0, originalX + 1, default: defaultValue],
                        originalBitmap[originalY + 1, originalX - 1, default: defaultValue],
                        originalBitmap[originalY + 1, originalX + 0, default: defaultValue],
                        originalBitmap[originalY + 1, originalX + 1, default: defaultValue],
                    ]

                    var hash = 0
                    for index in 0 ..< 9 {
                        hash = (hash << 1) | pixels[index]
                    }

                    targetBitmap[y, x] = input.enhancementMapping[hash]
                }
            }

            originalBitmap = targetBitmap
        }

        return originalBitmap.pixels.filter { $0 == 1 }.count
    }

    func solvePart1() -> Any {
        return solve(steps: 2)
    }

    func solvePart2() -> Any {
        return solve(steps: 50)
    }

    func parseInput(rawString: String) {
        var rawLines = rawString
            .components(separatedBy: CharacterSet.newlines)
            .filter { $0.isEmpty == false }

        let enhancementMapping: [Int] = rawLines.first!.compactMap { $0 == "#" ? 1 : 0 }

        rawLines.removeFirst()

        let pixels: [Int] = rawLines.joined().compactMap { $0 == "#" ? 1 : ($0 == "." ? 0 : nil) }

        let height = rawLines.count
        let width = pixels.count / height

        assert(enhancementMapping.count == 512)
        assert(width == height)

        input = .init(enhancementMapping: enhancementMapping, bitmap: .init(pixels: pixels, width: width, height: height))
    }
}
