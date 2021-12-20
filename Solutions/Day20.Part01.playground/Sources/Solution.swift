import Foundation

public struct Input {
    let enhancementMapping: [Int]
    let bitmap: Bitmap

    let nrOfSteps = 2
}

public struct Bitmap: CustomStringConvertible {
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

    public var description: String {
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

public func solutionFor(input: Input) -> Int {
    var originalBitmap = input.bitmap

    for stepIndex in 0 ..< input.nrOfSteps {
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

    print(originalBitmap)

    return originalBitmap.pixels.filter { $0 == 1 }.count
}
