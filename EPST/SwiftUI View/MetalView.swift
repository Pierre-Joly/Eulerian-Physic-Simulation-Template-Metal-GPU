import SwiftUI
import MetalKit

struct MetalView: View {
    @State private var metalView = MTKView()
    @State private var renderer: Renderer?
    @Binding var isRunning: Bool
    @Binding var restartToken: Int
    @Binding var substeps: Int
    @Binding var param: Float
    @Binding var gridResolutionX: Int
    @Binding var gridResolutionY: Int

    var body: some View {
        MetalViewRepresentable(metalView: $metalView)
            .onAppear {
                renderer = Renderer(
                    metalView: metalView,
                    gridResolutionX: gridResolutionX,
                    gridResolutionY: gridResolutionY,
                    substeps: substeps,
                    param: param
                )
                renderer?.isPaused = !isRunning
            }
            .onChange(of: isRunning) { _, newValue in
                renderer?.isPaused = !newValue
            }
            .onChange(of: restartToken) { _, _ in
                renderer?.resetSimulation()
            }
            .onChange(of: substeps) { _, newValue in
                renderer?.updateSubsteps(newValue)
            }
            .onChange(of: param) { _, newValue in
                renderer?.updateSimParams(param: param)
                renderer?.resetSimulation()
            }
            .onChange(of: gridResolutionX) { _, newValue in
                renderer?.updateGridSize(Nx: newValue, Ny: gridResolutionY)
            }
            .onChange(of: gridResolutionY) { _, newValue in
                renderer?.updateGridSize(Nx: gridResolutionX, Ny: newValue)
            }
    }
}

typealias ViewRepresentable = NSViewRepresentable

struct MetalViewRepresentable: ViewRepresentable {
  @Binding var metalView: MTKView

  func makeNSView(context: Context) -> some NSView {
    metalView
  }
  func updateNSView(_ uiView: NSViewType, context: Context) {
    updateMetalView()
  }

  func updateMetalView() {
  }
}
