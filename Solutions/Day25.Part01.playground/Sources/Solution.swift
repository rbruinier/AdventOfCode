import Foundation

public struct Input {
    let cells: [Cell]

    let width: Int
    let height: Int
}

public enum Cell {
    case empty
    case southbound
    case eastbound
}

func printCells(cells: [Cell], width: Int, height: Int) {
    var index = 0
    for _ in 0 ..< height {
        var result = ""

        for _ in 0 ..< width {
            switch cells[index] {
            case .eastbound:
                result += ">"
            case .southbound:
                result += "v"
            case .empty:
                result += "."
            }

            index += 1
        }

        print(result)
    }
}

func moveCells(forType cellType: Cell, cells: [Cell], width: Int, height: Int) -> (cells: [Cell], didMove: Bool) {
    var newCells = cells
    var didMove = false

    var index = 0
    for y in 0 ..< height {
        for x in 0 ..< width {
            defer {
                index += 1
            }

            guard cells[index] == cellType else {
                continue
            }

            let targetIndex: Int

            switch cellType {
            case .eastbound:
                targetIndex = (y * width) + ((x + 1) % width)
            case .southbound:
                targetIndex = (((y + 1) % height) * width) + x
            case .empty: fatalError()
            }

            if cells[targetIndex] == .empty {
                newCells[index] = .empty
                newCells[targetIndex] = cellType

                didMove = true
            }
        }
    }

    return (cells: newCells, didMove: didMove)
}

public func solutionFor(input: Input) -> Int {
    printCells(cells: input.cells, width: input.width, height: input.height)

    var cells = input.cells
    var didMove = true
    var stepCount = 0

    while didMove {
        didMove = false

        var result = moveCells(forType: .eastbound, cells: cells, width: input.width, height: input.height)

        didMove = result.didMove || didMove

        result = moveCells(forType: .southbound, cells: result.cells, width: input.width, height: input.height)

        didMove = result.didMove || didMove

        cells = result.cells
        stepCount += 1
    }

    print("Final grid:")

    printCells(cells: cells, width: input.width, height: input.height)

    return stepCount
}

