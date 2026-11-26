import UIKit
import Metal
import MetalKit
import simd

final class GameVC: UIViewController, MTKViewDelegate, UIDocumentPickerDelegate {
    private var mtkView: MTKView!
    private var device: MTLDevice!
    private var queue: MTLCommandQueue!
    private var pso: MTLRenderPipelineState!
    private var mesh: ChunkMesh!
    private var atlas: TextureAtlas!

    private var yaw: Float = 0.6
    private var pitch: Float = -0.25
    private var warningToken: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.965, green: 0.969, blue: 0.996, alpha: 1)

        guard let dev = MTLCreateSystemDefaultDevice() else { return }
        device = dev
        queue = dev.makeCommandQueue()

        mtkView = MTKView(frame: view.bounds, device: dev)
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mtkView.clearColor = MTLClearColorMake(0.965, 0.969, 0.996, 1)
        mtkView.delegate = self
        view.addSubview(mtkView)

        let lib = dev.makeDefaultLibrary()!
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = lib.makeFunction(name: "vs_main")
        rpd.fragmentFunction = lib.makeFunction(name: "fs_main")
        rpd.vertexDescriptor = ChunkMesh.descriptor()
        rpd.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pso = try! dev.makeRenderPipelineState(descriptor: rpd)

        mesh = ChunkMesh(device: dev)
        atlas = TextureAtlas(device: dev)

        let title = TitleView(frame: .zero)
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            title.widthAnchor.constraint(equalToConstant: 220),
            title.heightAnchor.constraint(equalToConstant: 80)
        ])

        let importBtn = UIButton(type: .system)
        importBtn.setTitle("Import Textures", for: .normal)
        importBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        importBtn.translatesAutoresizingMaskIntoConstraints = false
        importBtn.addTarget(self, action: #selector(importTextures), for: .touchUpInside)
        view.addSubview(importBtn)
        NSLayoutConstraint.activate([
            importBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            importBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])

        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        mtkView.addGestureRecognizer(pan)

        warningToken = MemoryBudget.install(onWarning: { [weak self] in
            // v1 owns exactly one chunk; policy hook is pinned here for later
            _ = self
        })
    }

    @objc private func onPan(_ g: UIPanGestureRecognizer) {
        let d = g.translation(in: mtkView)
        yaw += Float(d.x) * 0.006
        pitch = max(-1.2, min(1.2, pitch - Float(d.y) * 0.006))
        g.setTranslation(.zero, in: mtkView)
    }

    @objc private func importTextures() {
        let p = AssetImporter.makePicker()
        p.delegate = self
        present(p, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        AssetImporter.copyIntoDocuments(urls)
        atlas = TextureAtlas(device: device)
    }

    private func perspective(fovy: Float, aspect: Float, near: Float, far: Float) -> simd_float4x4 {
        let y = 1 / tan(fovy * 0.5)
        let x = y / aspect
        let z = far / (near - far)
        return simd_float4x4(columns: (
            SIMD4<Float>(x, 0, 0, 0),
            SIMD4<Float>(0, y, 0, 0),
            SIMD4<Float>(0, 0, z, -1),
            SIMD4<Float>(0, 0, z * near, 0)
        ))
    }

    private func lookAt(eye: SIMD3<Float>, center: SIMD3<Float>) -> simd_float4x4 {
        let f = normalize(center - eye)
        let s = normalize(cross(f, SIMD3<Float>(0, 1, 0)))
        let u = cross(s, f)
        return simd_float4x4(columns: (
            SIMD4<Float>( s.x,  u.x, -f.x, 0),
            SIMD4<Float>( s.y,  u.y, -f.y, 0),
            SIMD4<Float>( s.z,  u.z, -f.z, 0),
            SIMD4<Float>(-dot(s, eye), -dot(u, eye), dot(f, eye), 1)
        ))
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let rpd = view.currentRenderPassDescriptor,
              let cmd = queue.makeCommandBuffer(),
              let enc = cmd.makeRenderCommandEncoder(descriptor: rpd) else { return }

        let aspect = Float(view.drawableSize.width / max(1, view.drawableSize.height))
        let eye = SIMD3<Float>(1.7, 1.4, 2.6)
        let forward = SIMD3<Float>(
            cos(pitch) * sin(yaw),
            sin(pitch),
            -cos(pitch) * cos(yaw)
        )
        var mvp = perspective(fovy: .pi / 3, aspect: aspect, near: 0.1, far: 100)
            * lookAt(eye: eye, center: eye + forward)

        enc.setRenderPipelineState(pso)
        enc.setCullMode(.none)
        enc.setVertexBuffer(mesh.vertexBuffer, offset: 0, index: 0)
        enc.setVertexBytes(&mvp, length: MemoryLayout<simd_float4x4>.size, index: 1)
        enc.setFragmentTexture(atlas.top, index: 0)
        enc.setFragmentTexture(atlas.dirt, index: 1)
        enc.setFragmentTexture(atlas.side, index: 2)
        enc.setFragmentSamplerState(atlas.samplerState, index: 0)
        enc.drawIndexedPrimitives(type: .triangle,
                                  indexCount: mesh.indexCount,
                                  indexType: .uint16,
                                  indexBuffer: mesh.indexBuffer,
                                  indexBufferOffset: 0)
        enc.endEncoding()
        if let drawable = view.currentDrawable { cmd.present(drawable) }
        cmd.commit()
    }
}
