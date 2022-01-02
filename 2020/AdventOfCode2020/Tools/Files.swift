import Foundation

func getRawInputStringFor(day: Int) -> String {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let bundleURL = URL(fileURLWithPath: "Inputs.bundle", relativeTo: currentDirectoryURL)
    let bundle = Bundle(url: bundleURL)!

    let fileURL = bundle.url(forResource: String(format: "Day%02d", day), withExtension: "txt")!

    return try! String(contentsOf: fileURL)
}
