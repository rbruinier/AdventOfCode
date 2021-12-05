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
        if line.isHorizontal {
            let yOffset = line.y1 * width

            let startX = min(line.x1, line.x2)
            let endX = max(line.x1, line.x2)

            for x in startX ... endX {
                items[yOffset + x].counter += 1
            }
        } else if line.isVertical {
            let xOffset = line.x1

            let startY = min(line.y1, line.y2)
            let endY = max(line.y1, line.y2)

            for y in startY ... endY {
                items[xOffset + (y * width)].counter += 1
            }
        } else {
            let deltaX = abs(line.x2 - line.x1)
            let deltaY = abs(line.y2 - line.y1)

            var startX = line.x1
            var endX = line.x2
            var startY = line.y1
            var endY = line.y2

            if deltaX >= deltaY {
                if endX < startX {
                    swap(&startX, &endX)
                    swap(&startY, &endY)
                }

                var currentY = startY

                for x in startX ... endX {
                    items[(currentY * width) + x].counter += 1

                    currentY += (endY > startY) ? 1 : -1
                }
            } else {
                if endY < startY {
                    swap(&startX, &endX)
                    swap(&startY, &endY)
                }

                var currentX = startX

                for y in startY ... endY {
                    items[currentX + (y * width)].counter += 1

                    currentX += (endX > startX) ? 1 : -1
                }
            }
        }
    }
}

public struct Line {
    let x1: Int
    let y1: Int

    let x2: Int
    let y2: Int

    var isHorizontal: Bool {
        return y1 == y2
    }

    var isVertical: Bool {
        return x1 == x2
    }
}

public func solutionFor(input: Input) -> Int {
    print(input)

    var grid = Grid(width: input.gridWidth, height: input.gridHeight)

    for line in input.lines {
        grid.addLine(line)
    }

    return grid.numberOfItemsWithMinimumCounter(2)
}
