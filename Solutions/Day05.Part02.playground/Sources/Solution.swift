import Foundation

public struct Input {
    let lines: [Line]

    let gridWidth: Int
    let gridHeight: Int
}

public struct Grid {
    struct Item {
        var counter = 0
    }

    let width: Int
    let height: Int

    var items: [Item]

    func numberOfItemsWithMinimumCounter(_ minimumCounter: Int) -> Int {
        items.reduce(0) { result, item in
            return result + (item.counter >= minimumCounter ? 1 : 0)
        }
    }

    init(width: Int, height: Int) {
        self.width = width
        self.height = height

        items = Array(repeating: .init(), count: width * height)
    }

    mutating func addLine(_ line: Line) {
        var xInc = 0
        var yInc = 0

        let drawHorizontal: Bool

        switch line.orientation {
        case .horizontal:
            drawHorizontal = true
        case .vertical:
            drawHorizontal = false
        case.diagonal:
            if abs(line.x2 - line.x1) >= abs(line.y2 - line.y1) {
                drawHorizontal = true

                yInc = line.y2 > line.y1 ? 1 : -1
            } else {
                drawHorizontal = false

                xInc = line.x2 > line.x1 ? 1 : -1
            }

            break
        }

        if drawHorizontal {
            var startX = line.x1
            var endX = line.x2
            var currentY = line.y1

            if endX < startX {
                startX = line.x2
                endX = line.x1
                currentY = line.y2

                yInc = -yInc
            }

            for x in startX ... endX {
                items[(currentY * width) + x].counter += 1

                currentY += yInc
            }
        } else {
            var startY = line.y1
            var endY = line.y2
            var currentX = line.x1

            if endY < startY {
                startY = line.y2
                endY = line.y1
                currentX = line.x2

                xInc = -xInc
            }

            for y in startY ... endY {
                items[currentX + (y * width)].counter += 1

                currentX += xInc
            }
        }
    }
}

public struct Line {
    enum Orientation {
        case horizontal
        case vertical
        case diagonal
    }

    let x1: Int
    let y1: Int

    let x2: Int
    let y2: Int

    var orientation: Orientation {
        if y1 == y2 {
            return .horizontal
        } else if x1 == x2 {
            return .vertical
        } else {
            return .diagonal
        }
    }
}

public func solutionFor(input: Input) -> Int {
    var grid = Grid(width: input.gridWidth, height: input.gridHeight)

    for line in input.lines {
        grid.addLine(line)
    }

    return grid.numberOfItemsWithMinimumCounter(2)
}
