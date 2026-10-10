import Foundation

/// Owns only temporary export sources, never document-picker destinations.
final class QuestwellExportFiles {
  enum Failure: Error { case unsafeDirectory, invalidData }
  private let manager: FileManager
  private let root: URL

  init(caches: URL, manager: FileManager = .default) {
    self.manager = manager
    root = caches.appendingPathComponent("QuestwellAccountExport", isDirectory: true)
  }

  func recover() throws {
    // Refuse links rather than traversing an unexpected replacement directory.
    if let type = try? manager.attributesOfItem(atPath: root.path)[.type] {
      guard type as? FileAttributeType == .typeDirectory else {
        throw Failure.unsafeDirectory
      }
    } else if manager.fileExists(atPath: root.path) {
      throw Failure.unsafeDirectory
    } else {
      try manager.createDirectory(at: root, withIntermediateDirectories: false)
    }
    for child in try manager.contentsOfDirectory(at: root, includingPropertiesForKeys: nil) {
      // This entire private cache directory belongs to this adapter. Removal of
      // a symlink removes the link itself; no destination URL enters this API.
      try manager.removeItem(at: child)
    }
  }

  func stage(_ data: Data) throws -> URL {
    guard !data.isEmpty, data.count <= 40 * 1024 * 1024 else {
      throw Failure.invalidData
    }
    try recover()
    let source = root.appendingPathComponent("questwell-account-export.json")
    #if os(iOS)
    try data.write(to: source, options: [.atomic, .completeFileProtection])
    #else
    try data.write(to: source, options: .atomic)
    #endif
    return source
  }

  /// Compatibility cleanup for the former file_picker 8.1.7 adapter. Call only
  /// while Documents is private: never scan a user-visible Documents folder.
  static func recoverLegacy(documents: URL, isPrivate: Bool,
                            manager: FileManager = .default) throws {
    guard isPrivate else { return }
    let pattern = "^questwell-account-export-[0-9a-f]{24}\\.json$"
    for file in try manager.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil) {
      let name = file.lastPathComponent
      guard let match = name.range(of: pattern, options: .regularExpression),
            match.lowerBound == name.startIndex, match.upperBound == name.endIndex,
            try manager.attributesOfItem(atPath: file.path)[.type] as? FileAttributeType == .typeRegular
      else { continue }
      try manager.removeItem(at: file)
    }
  }
}
