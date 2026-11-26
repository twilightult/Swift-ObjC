import Metal
import MetalKit
import Foundation

// Three 16x16 slots. Real PNGs come from Documents/assets/ via Files app.
// If not imported yet, solid colors keep the first frame alive.
final class TextureAtlas {
    let top: MTLTexture
    let dirt: MTLTexture
    let side: MTLTexture
    let samplerState: MTLSamplerState

    private static func assetDir() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("assets", isDirectory: true)
    }

    private static func solid(_ device: MTLDevice, _ r: UInt8, _ g: UInt8, _ b: UInt8) -> MTLTexture {
        let d = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                         width: 16, height: 16, mipmapped: false)
        d.usage = [.shaderRead]
        d.storageMode = .shared
        let t = device.makeTexture(descriptor: d)!
        var px = [UInt8](repeating: 0, count: 16 * 16 * 4)
        for i in stride(from: 0, to: px.count, by: 4) {
            px[i] = r; px[i+1] = g; px[i+2] = b; px[i+3] = 255
        }
        t.replace(region: MTLRegionMake2D(0, 0, 16, 16), mipmapLevel: 0,
                  withBytes: &px, bytesPerRow: 64)
        return t
    }

    init(device: MTLDevice) {
        let loader = MTKTextureLoader(device: device)
        let opts: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .generateMipmaps: false,
            .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            .textureStorageMode: NSNumber(value: MTLStorageMode.shared.rawValue)
        ]
        let dir = TextureAtlas.assetDir()

        func load(_ name: String, _ r: UInt8, _ g: UInt8, _ b: UInt8) -> MTLTexture {
            let url = dir.appendingPathComponent(name)
            if let t = try? loader.newTexture(URL: url, options: opts) { return t }
            return TextureAtlas.solid(device, r, g, b)
        }

        top  = load("grass_block_top.png",  114, 174,  71)
        dirt = load("dirt.png",             134,  96,  67)
        side = load("grass_block_side.png", 114, 174,  71)

        let sd = MTLSamplerDescriptor()
        sd.minFilter = .nearest
        sd.magFilter = .nearest
        sd.mipFilter = .nearest
        sd.sAddressMode = .clampToEdge
        sd.tAddressMode = .clampToEdge
        samplerState = device.makeSamplerState(descriptor: sd)!
    }
}
