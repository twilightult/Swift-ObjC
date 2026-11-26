import Metal

// One cube: 6 faces x 4 verts = 24 verts, 36 indices.
// face id: 0 top / 1 bottom / 2..5 side
struct MCVertex {
    var px: Float, py: Float, pz: Float
    var u: Float, v: Float
    var face: Float
}

final class ChunkMesh {
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let indexCount = 36

    init(device: MTLDevice) {
        let h: Float = 0.5
        var v: [MCVertex] = []
        var idx: [UInt16] = []

        // (4 corners, face id) in CCW-ish order; cullMode is .none
        let faces: [([SIMD3<Float>], Float)] = [
            ([SIMD3(-h, h,-h), SIMD3( h, h,-h), SIMD3(-h, h, h), SIMD3( h, h, h)], 0), // +Y top
            ([SIMD3(-h,-h, h), SIMD3( h,-h, h), SIMD3(-h,-h,-h), SIMD3( h,-h,-h)], 1), // -Y dirt
            ([SIMD3(-h,-h, h), SIMD3( h,-h, h), SIMD3(-h, h, h), SIMD3( h, h, h)], 2), // +Z
            ([SIMD3( h,-h,-h), SIMD3(-h,-h,-h), SIMD3( h, h,-h), SIMD3(-h, h,-h)], 3), // -Z
            ([SIMD3( h,-h, h), SIMD3( h,-h,-h), SIMD3( h, h, h), SIMD3( h, h,-h)], 4), // +X
            ([SIMD3(-h,-h,-h), SIMD3(-h,-h, h), SIMD3(-h, h,-h), SIMD3(-h, h, h)], 5), // -X
        ]
        let uvs: [SIMD2<Float>] = [SIMD2(0,0), SIMD2(1,0), SIMD2(0,1), SIMD2(1,1)]

        for (corners, fid) in faces {
            let base = UInt16(v.count)
            for i in 0..<4 {
                v.append(MCVertex(px: corners[i].x, py: corners[i].y, pz: corners[i].z,
                                  u: uvs[i].x, v: uvs[i].y, face: fid))
            }
            idx += [base, base+1, base+2, base+2, base+1, base+3]
        }

        let vs = MemoryLayout<MCVertex>.stride * v.count
        let iss = MemoryLayout<UInt16>.stride * idx.count
        vertexBuffer = device.makeBuffer(bytes: &v, length: vs, options: [.storageModeShared])!
        indexBuffer  = device.makeBuffer(bytes: &idx, length: iss, options: [.storageModeShared])!
    }

    static func descriptor() -> MTLVertexDescriptor {
        let d = MTLVertexDescriptor()
        d.attributes[0].format = .float3
        d.attributes[0].offset = 0
        d.attributes[0].bufferIndex = 0
        d.attributes[1].format = .float2
        d.attributes[1].offset = 12
        d.attributes[1].bufferIndex = 0
        d.attributes[2].format = .float
        d.attributes[2].offset = 20
        d.attributes[2].bufferIndex = 0
        d.layouts[0].stride = MemoryLayout<MCVertex>.stride
        return d
    }
}
