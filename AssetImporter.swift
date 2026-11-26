import Foundation

/// 把用户本机文件原样读成 Data：不转 String、不重编码、不另存、不标准化。
/// 解出的资源只回内存喂图集，不写 Documents / UserDefaults / Keychain。
enum AssetImporter {
    static func read(_ url: URL) throws -> Data {
        let secured = url.startAccessingSecurityScopedResource()
        defer { if secured { url.stopAccessingSecurityScopedResource() } }
        return try Data(contentsOf: url)
    }

    static func pngs(in dir: URL) throws -> [URL] {
        try FileManager.default
            .contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension.lowercased() == "png" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
