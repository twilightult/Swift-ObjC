import Foundation

extension AssetImporter {
    /// List PNG files inside a user-selected folder.
    /// No copy, no re-encode: only URLs are enumerated.
    static func pngs(in dir: URL) throws -> [URL] {
        let fm = FileManager.default
        let secured = dir.startAccessingSecurityScopedResource()
        defer { if secured { dir.stopAccessingSecurityScopedResource() } }
        let items = try fm.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        return items
            .filter { $0.pathExtension.lowercased() == "png" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
