import Foundation

final class Day22Solver: DaySolver {
    let dayNumber: Int = 22

    private var input: Input!

    private struct Input {
        let steps: [Step]
    }

    private struct Step {
        let box: Box
        let isOn: Bool
    }

    private struct Point {
        var x: Int
        var y: Int
        var z: Int
    }

    /*
     Positive box contributes to count, negative cube decreases the total count.

     Instead of subdividing actual cubes and getting tons of little cubes and having to deal with edge cases instead the overlapping part
     will be negating cube. The original will also be added so the overlapping part will be subtracted resulting in correct number of cubes.
     */
    private struct Box {
        let minPoint: Point
        let maxPoint: Point

        let sign: Int

        var numberOfCubes: Int {
            (maxPoint.x - minPoint.x + 1)
                * (maxPoint.y - minPoint.y + 1)
                * (maxPoint.z - minPoint.z + 1)
        }

        func intersects(_ rhs: Box) -> Bool {
            if rhs.minPoint.x > maxPoint.x
                || rhs.maxPoint.x < minPoint.x
                || rhs.minPoint.y > maxPoint.y
                || rhs.maxPoint.y < minPoint.y
                || rhs.minPoint.z > maxPoint.z
                || rhs.maxPoint.z < minPoint.z {
                return false
            }

            return true
        }

        func intersect(_ rhs: Box) -> Box {
            let intersectionMinPoint = Point(
                x: max(minPoint.x, rhs.minPoint.x),
                y: max(minPoint.y, rhs.minPoint.y),
                z: max(minPoint.z, rhs.minPoint.z))

            let intersectionMaxPoint = Point(
                x: min(maxPoint.x, rhs.maxPoint.x),
                y: min(maxPoint.y, rhs.maxPoint.y),
                z: min(maxPoint.z, rhs.maxPoint.z))

            return .init(minPoint: intersectionMinPoint, maxPoint: intersectionMaxPoint, sign: -sign)
        }
    }


    private func addBox(_ box: Box, isOn: Bool, to boxes: [Box]) -> [Box] {
        var newBoxes: [Box] = boxes

        for existingBox in boxes where existingBox.intersects(box) {
            newBoxes.append(existingBox.intersect(box))
        }

        if isOn {
            newBoxes.append(box)
        }

        return newBoxes
    }

    func solvePart1() -> Any {
        let steps = input.steps.filter {
            guard
                (-50 ... 50).contains($0.box.minPoint.x),
                (-50 ... 50).contains($0.box.minPoint.y),
                (-50 ... 50).contains($0.box.minPoint.z),
                (-50 ... 50).contains($0.box.maxPoint.x),
                (-50 ... 50).contains($0.box.maxPoint.y),
                (-50 ... 50).contains($0.box.maxPoint.z)
            else {
                return false
            }

            return true
        }

        var boxes: [Box] = [steps[0].box]

        var stepIndex = 2
        for step in input.steps[1 ..< steps.endIndex] {
            boxes = addBox(step.box, isOn: step.isOn, to: boxes)

            stepIndex += 1
        }

        let count = boxes.reduce(0) { result, box in
            return result + (box.numberOfCubes * box.sign)
        }

        return count
    }

    func solvePart2() -> Any {
        var boxes: [Box] = [input.steps[0].box]

        var stepIndex = 2
        for step in input.steps[1 ..< input.steps.endIndex] {
            boxes = addBox(step.box, isOn: step.isOn, to: boxes)

            stepIndex += 1
        }

        let count = boxes.reduce(0) { result, box in
            return result + (box.numberOfCubes * box.sign)
        }

        return count        
    }

    func parseInput(rawString: String) {
        let rawLines = rawString
            .components(separatedBy: CharacterSet.newlines)
            .filter { $0.isEmpty == false }

        let steps: [Step] = rawLines.map {
            var minPoint = Point(x: Int.max, y: Int.max, z: Int.max)
            var maxPoint = Point(x: Int.min, y: Int.min, z: Int.min)

            let components = $0.components(separatedBy: " ")

            components[1]
                .components(separatedBy: ",")
                .forEach {
                    let operands = $0.components(separatedBy: "=")
                    let range = operands[1].components(separatedBy: "..")

                    switch operands[0] {
                    case "x":
                        minPoint.x = min(minPoint.x, Int(range[0])!)
                        maxPoint.x = max(maxPoint.x, Int(range[1])!)
                    case "y":
                        minPoint.y = min(minPoint.y, Int(range[0])!)
                        maxPoint.y = max(maxPoint.y, Int(range[1])!)
                    case "z":
                        minPoint.z = min(minPoint.z, Int(range[0])!)
                        maxPoint.z = max(maxPoint.z, Int(range[1])!)
                    default:
                        fatalError()
                    }
                }

            if components[0] == "on" {
                return .init(box: .init(minPoint: minPoint, maxPoint: maxPoint, sign: 1), isOn: true)
            } else {
                return .init(box: .init(minPoint: minPoint, maxPoint: maxPoint, sign: -1), isOn: false)
            }
        }

        input = .init(steps: steps)
    }
}
