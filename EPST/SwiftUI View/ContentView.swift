import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @State private var isRunning: Bool = true
    @State private var restartToken: Int = 0
    @State private var substeps: Int = 50
    @State private var param: Float = 0.50
    @State private var gridResolutionX: Int = 2016
    @State private var gridResolutionY: Int = 736
    @AppStorage("uiTheme") private var themeModeRaw: String = ThemeMode.system.rawValue

    private var themeMode: ThemeMode {
        ThemeMode(rawValue: themeModeRaw) ?? .system
    }

    private var themeBinding: Binding<ThemeMode> {
        Binding(
            get: { ThemeMode(rawValue: themeModeRaw) ?? .system },
            set: { themeModeRaw = $0.rawValue }
        )
    }

    var body: some View {
        #if os(macOS)
        content
            .onAppear { applyAppearance(themeMode) }
            .onChange(of: themeMode) { _, newValue in
                applyAppearance(newValue)
            }
        #else
        if themeMode == .system {
            content
        } else {
            content.preferredColorScheme(themeMode.colorScheme)
        }
        #endif
    }

    private var content: some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.width < 980
            ZStack {
                BackgroundView()
                Group {
                    if isCompact {
                        VStack(spacing: 20) {
                            ControlPanel(
                                isRunning: $isRunning,
                                restartToken: $restartToken,
                                substeps: $substeps,
                                param: $param,
                                gridResolutionX: $gridResolutionX,
                                gridResolutionY: $gridResolutionY,
                                themeMode: themeBinding
                            )
                            SimulationSurface(
                                containerSize: proxy.size,
                                isRunning: $isRunning,
                                restartToken: $restartToken,
                                substeps: $substeps,
                                param: $param,
                                gridResolutionX: $gridResolutionX,
                                gridResolutionY: $gridResolutionY
                            )
                        }
                    } else {
                        HStack(spacing: 24) {
                            ControlPanel(
                                isRunning: $isRunning,
                                restartToken: $restartToken,
                                substeps: $substeps,
                                param: $param,
                                gridResolutionX: $gridResolutionX,
                                gridResolutionY: $gridResolutionY,
                                themeMode: themeBinding
                            )
                            SimulationSurface(
                                containerSize: proxy.size,
                                isRunning: $isRunning,
                                restartToken: $restartToken,
                                substeps: $substeps,
                                param: $param,
                                gridResolutionX: $gridResolutionX,
                                gridResolutionY: $gridResolutionY
                            )
                        }
                    }
                }
                .padding(28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    #if os(macOS)
    private func applyAppearance(_ mode: ThemeMode) {
        switch mode {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
    #endif
}
