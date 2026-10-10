import Foundation

@main
struct ExportRecoveryTest {
  static func main() throws {
    let manager = FileManager.default
    if CommandLine.arguments.count == 3 && CommandLine.arguments[1] == "--interrupt" {
      let caches = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
      _ = try QuestwellExportFiles(caches: caches).stage(Data("synthetic export".utf8))
      exit(86) // No cleanup: model process termination while the picker is open.
    }
    let base = manager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try manager.createDirectory(at: base, withIntermediateDirectories: true)
    defer { try? manager.removeItem(at: base) }
    let files = QuestwellExportFiles(caches: base)
    let data = Data("synthetic export".utf8)
    let saved = base.appendingPathComponent("user-selected.json")
    let unrelated = base.appendingPathComponent("other-cache")
    try data.write(to: unrelated)

    // Success: destination copy survives cleanup and another launch.
    let source = try files.stage(data)
    guard try Data(contentsOf: source) == data else { fatalError("staged bytes differ") }
    try manager.copyItem(at: source, to: saved)
    try files.recover()
    try QuestwellExportFiles(caches: base).recover()
    guard !manager.fileExists(atPath: source.path),
          try Data(contentsOf: saved) == data,
          try Data(contentsOf: unrelated) == data else { fatalError("success cleanup boundary") }

    // Cancellation cleanup is idempotent and leaves no source.
    _ = try files.stage(data)
    try files.recover()
    try files.recover()
    guard !manager.fileExists(atPath: source.path) else { fatalError("cancel cleanup") }

    // A separate process stages and exits without callbacks; a fresh owner recovers it.
    let child = Process()
    child.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
    child.arguments = ["--interrupt", base.path]
    try child.run()
    child.waitUntilExit()
    guard child.terminationStatus == 86, manager.fileExists(atPath: source.path) else {
      fatalError("interruption fixture")
    }
    try QuestwellExportFiles(caches: base).recover()
    guard !manager.fileExists(atPath: source.path), try Data(contentsOf: saved) == data else {
      fatalError("restart recovery")
    }

    // A source replaced with a symlink must never remove its target.
    try manager.createSymbolicLink(at: source, withDestinationURL: saved)
    try files.recover()
    guard try Data(contentsOf: saved) == data else { fatalError("followed source link") }

    // Refuse a replaced root (including a dangling link); never traverse it.
    let root = source.deletingLastPathComponent()
    try manager.removeItem(at: root)
    try manager.createSymbolicLink(at: root, withDestinationURL: base)
    expectFailure { try files.recover() }
    guard try Data(contentsOf: saved) == data else { fatalError("followed root link") }
    try manager.removeItem(at: root)
    try manager.createSymbolicLink(at: root, withDestinationURL: base.appendingPathComponent("missing"))
    expectFailure { try files.recover() }
    try manager.removeItem(at: root)
    try data.write(to: root)
    expectFailure { _ = try files.stage(data) }
    try manager.removeItem(at: root)
    expectFailure { _ = try files.stage(Data()) }
    expectFailure { _ = try files.stage(Data(count: 40 * 1024 * 1024 + 1)) }

    // Legacy recovery is narrow, nonrecursive, and disabled for shared Documents.
    let documents = base.appendingPathComponent("Documents")
    try manager.createDirectory(at: documents, withIntermediateDirectories: false)
    let legacy = documents.appendingPathComponent("questwell-account-export-0123456789abcdef01234567.json")
    let lookalike = documents.appendingPathComponent("questwell-account-export-mine.json")
    let link = documents.appendingPathComponent("questwell-account-export-aaaaaaaaaaaaaaaaaaaaaaaa.json")
    let directory = documents.appendingPathComponent("questwell-account-export-bbbbbbbbbbbbbbbbbbbbbbbb.json")
    try data.write(to: legacy)
    try data.write(to: lookalike)
    try manager.createSymbolicLink(at: link, withDestinationURL: saved)
    try manager.createDirectory(at: directory, withIntermediateDirectories: false)
    let nested = directory.appendingPathComponent(legacy.lastPathComponent)
    try data.write(to: nested)
    try QuestwellExportFiles.recoverLegacy(documents: documents, isPrivate: false)
    guard manager.fileExists(atPath: legacy.path) else { fatalError("shared Documents scanned") }
    try QuestwellExportFiles.recoverLegacy(documents: documents, isPrivate: true)
    guard !manager.fileExists(atPath: legacy.path),
          try Data(contentsOf: lookalike) == data,
          try Data(contentsOf: nested) == data,
          try Data(contentsOf: link) == data else { fatalError("legacy cleanup boundary") }
    print("PASS: export copy, cancel, process interruption, restart, idempotency, symlinks, invalid input and legacy boundaries")
  }

  static func expectFailure(_ operation: () throws -> Void) {
    do { try operation() } catch { return }
    fatalError("unsafe operation unexpectedly succeeded")
  }
}
