import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!

    var camera = OrthographicCamera()
    var isPaused: Bool = false

    var physicRenderPass: PhysicRenderPass
    var graphicRenderPass: GraphicRenderPass
    var quadModel: QuadModel
    var gridResolutionX: Int
    var gridResolutionY: Int

    var substeps: Int
    var param: Float

    init(metalView: MTKView, gridResolutionX: Int, gridResolutionY: Int, substeps: Int, param: Float) {
        self.gridResolutionX = gridResolutionX
        self.gridResolutionY = gridResolutionY
        self.substeps = substeps
        self.param = param

        // Create the device and command queue
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue()
        else { fatalError("GPU not available") }
        
        Self.device = device
        Self.commandQueue = commandQueue
        metalView.device = device

        // Create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        
        // Mesh Model
        self.quadModel = QuadModel(device: device)
        
        // Render Pass
        self.physicRenderPass = PhysicRenderPass(device: Self.device,
                                                 commandQueue: Self.commandQueue,
                                                 Nx: gridResolutionX,
                                                 Ny: gridResolutionY,
                                                 substeps: substeps,
                                                 param: param)

        self.graphicRenderPass = GraphicRenderPass(view: metalView,
                                                   physicPass: physicRenderPass,
                                                   quad: quadModel,
                                                   camera: self.camera)

        super.init()
        
        metalView.clearColor = MTLClearColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 1.0)

        metalView.delegate = self
        mtkView(
            metalView,
            drawableSizeWillChange: metalView.drawableSize)
        }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize)
    {
        camera.update(size: size)
        graphicRenderPass.updateCamera(camera)
    }

    func draw(in view: MTKView) {
        // set up command
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor
            else { return }
        
        // Physic computation
        if !isPaused {
            physicRenderPass.draw(commandBuffer: commandBuffer)
        }
        
        // Graphic rendering
        graphicRenderPass.descriptor = descriptor
        graphicRenderPass.draw(commandBuffer: commandBuffer)
        
        // Finish the frame
        guard let drawable = view.currentDrawable
            else { return }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension Renderer {
    func resetSimulation() {
        physicRenderPass.resetState()
    }

    func updateSubsteps(_ value: Int) {
        substeps = value
        physicRenderPass.updateSubsteps(value)
    }

    func updateSimParams(param: Float) {
        self.param = param
        physicRenderPass.updateSimParams(param: param)
        graphicRenderPass.simParams = physicRenderPass.simParams
    }

    func updateGridSize(Nx: Int, Ny: Int) {
        gridResolutionX = Nx
        gridResolutionY = Ny
        physicRenderPass.updateGridSize(Nx: Nx, Ny: Ny)
        graphicRenderPass.mesh = physicRenderPass.mesh
        graphicRenderPass.informationBuffer = physicRenderPass.informationBuffer
    }

    
}
