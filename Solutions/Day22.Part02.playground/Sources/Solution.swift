import Foundation

public struct Input {
    let steps: [Step]
}

public struct Step {
    let box: Box
    let isOn: Bool
}

public struct Point {
    var x: Int
    var y: Int
    var z: Int
}

/*
 Positive box contributes to count, negative cube decreases the total count.

 Instead of subdividing actual cubes and getting tons of little cubes and having to deal with edge cases instead the overlapping part
 will be negating cube. The original will also be added so the overlapping part will be subtracted resulting in correct number of cubes.
 */
public struct Box {
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


func addBox(_ box: Box, isOn: Bool, to boxes: [Box]) -> [Box] {
    var newBoxes: [Box] = boxes

    for existingBox in boxes where existingBox.intersects(box) {
        newBoxes.append(existingBox.intersect(box))
    }

    if isOn {
        newBoxes.append(box)
    }

    return newBoxes
}

public func solutionFor(input: Input) -> Int {
    var boxes: [Box] = [input.steps[0].box]

    var stepIndex = 2
    for step in input.steps[1 ..< input.steps.endIndex] {
        print("Processing step \(stepIndex), current box count: \(boxes.count)")

        boxes = addBox(step.box, isOn: step.isOn, to: boxes)

        stepIndex += 1
    }

    let count = boxes.reduce(0) { result, box in
        return result + (box.numberOfCubes * box.sign)
    }

    return count
}
