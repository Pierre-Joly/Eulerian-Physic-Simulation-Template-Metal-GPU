import MetalKit

class PhysicRenderPass {
    // PSO
    var initialize: MTLComputePipelineState
    var physic: MTLComputePipelineState

    // Command queue
    let commandQueue: MTLCommandQueue

    // Device
    let device: MTLDevice

    // Constant
    var mesh: Mesh
    var substeps: Int
    var simParams: SimParams

    // Buffer
    var informationBuffer: MTLBuffer

    // Thread
    let threadgroupSize: MTLSize
    var threadgroupCount: MTLSize

    init(device: MTLDevice, commandQueue: MTLCommandQueue, Nx: Int, Ny: Int, substeps: Int, param: Float) {
        // Constants
        self.device = device
        self.commandQueue = commandQueue
        let clampedNx = max(1, Nx)
        let clampedNy = max(1, Ny)
        self.mesh = Mesh(
            Nx: UInt32(clampedNx),
            Ny: UInt32(clampedNy)
        )
        self.substeps = substeps

        self.simParams = SimParams(param: param)

        // Create compute pipeline states
        self.initialize = PipelineStates.createComputePSO(function: "initialize")
        self.physic = PipelineStates.createComputePSO(function: "physic")

        // Buffers
        guard
            let informationBuffer = device.makeBuffer(
                length: clampedNx * clampedNy * MemoryLayout<Float>.stride,
                options: .storageModePrivate
            )
        else {
            fatalError("Failed to create one or more buffers")
        }
        self.informationBuffer = informationBuffer

        // Threading
        self.threadgroupSize  = MTLSize(width: 256, height: 1, depth: 1)
        let count = mesh.Nx * mesh.Ny
        let groups = Int((count + 255) / 256)
        self.threadgroupCount = MTLSize(width: groups, height: 1, depth: 1)

        // Initialize the simulation
        resetState()
    }

    func draw(commandBuffer: MTLCommandBuffer) {
        let steps = max(1, substeps)
        for _ in 0..<steps {
            step(commandBuffer: commandBuffer)
        }
    }

    func resetState() {
        // Create a command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            fatalError("Failed to create command buffer or compute encoder")
        }

        // Bind Buffers
        encoder.setBytes(&mesh, length: MemoryLayout<Mesh>.stride, index: MeshBuffer.index)
        encoder.setBytes(&simParams, length: MemoryLayout<SimParams>.stride, index: SimParamsBuffer.index)
        encoder.setBuffer(informationBuffer, offset: 0, index: InformationBuffer.index)

        // Launch kernel
        encoder.setComputePipelineState(self.initialize)
        encoder.dispatchThreadgroups(self.threadgroupCount, threadsPerThreadgroup: self.threadgroupSize)

        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    func updateGridSize(Nx: Int, Ny: Int) {
        let clampedNx = max(1, Nx)
        let clampedNy = max(1, Ny)
        mesh = Mesh(
            Nx: UInt32(clampedNx),
            Ny: UInt32(clampedNy)
        )

        guard
            let informationBuffer = device.makeBuffer(
                length: clampedNx * clampedNy * MemoryLayout<Float>.stride,
                options: .storageModePrivate
            )
        else {
            fatalError("Failed to create one or more buffers")
        }
        self.informationBuffer = informationBuffer
        let count = Int(mesh.Nx * mesh.Ny)
        let groups = (count + 255) / 256
        threadgroupCount = MTLSize(width: groups, height: 1, depth: 1)
        resetState()
    }

    func updateSubsteps(_ value: Int) {
        substeps = max(1, value)
    }

    func updateSimParams(param: Float) {
        simParams = SimParams(param: param)
    }

    private func step(commandBuffer: MTLCommandBuffer) {
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else {
            fatalError("Failed to create compute command buffer")
        }

        // Bind Buffers
        encoder.setBytes(&mesh, length: MemoryLayout<Mesh>.stride, index: MeshBuffer.index)
        encoder.setBytes(&simParams, length: MemoryLayout<SimParams>.stride, index: SimParamsBuffer.index)
        encoder.setBuffer(self.informationBuffer, offset: 0, index: InformationBuffer.index)

        // Launch kernel
        encoder.setComputePipelineState(self.physic)
        encoder.dispatchThreadgroups(self.threadgroupCount, threadsPerThreadgroup: self.threadgroupSize)

        encoder.endEncoding()
    }
}
