import UIKit

// ARC does not collect, GC does not exist, background processes do not
// carry us. Resident chunk count is our own policy, driven by the
// per-process high-water mark.
enum MemoryBudget {
    static func residentChunkCount() -> Int {
        let perChunk = 64 * 1024
        let n = Int(MCMemoryProbe.availableBytes()) / perChunk
        return max(1, min(8, n))
    }

    @discardableResult
    static func install(onWarning unload: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil, queue: .main) { _ in unload() }
    }
}
