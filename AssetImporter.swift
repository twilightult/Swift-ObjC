import UIKit
import UniformTypeIdentifiers
import Foundation

enum AssetImporter {
    static func makePicker() -> UIDocumentPickerViewController {
        let p = UIDocumentPickerViewController(forOpeningContentTypes: [.png])
        p.allowsMultipleSelection = true
        return p
    }

    // Data in, Data out. No UIImage round-trip, no re-encode,
    // so LSB watermark pixels survive byte for byte.
    static func copyIntoDocuments(_ urls: [URL]) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("assets", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        for u in urls {
            let scoped = u.startAccessingSecurityScopedResource()
            defer { if scoped { u.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: u) else { continue }
            try? data.write(to: dir.appendingPathComponent(u.lastPathComponent), options: .atomic)
        }
    }
}
