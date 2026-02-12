import SwiftUI
import Foundation

struct ControlPanel: View {
    @Binding var isRunning: Bool
    @Binding var restartToken: Int
    @Binding var substeps: Int
    @Binding var param: Float
    @Binding var gridResolutionX: Int
    @Binding var gridResolutionY: Int
    @Binding var themeMode: ThemeMode
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let theme = AppTheme.current(colorScheme)
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("EPST Workspace")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text("Eulerian Physic Simulation Template")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1.4)
            }

            HStack(spacing: 10) {
                InfoPill(title: "Grid", value: "\(gridResolutionX) x \(gridResolutionY)")
                InfoPill(title: "Substeps", value: "\(substeps)")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Appearance")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
                Picker("", selection: $themeMode) {
                    ForEach(ThemeMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            TransportControls(isRunning: $isRunning, restartToken: $restartToken)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Controls")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textSecondary)

                    ControlStepper(
                        title: "Grid Nx",
                        value: $gridResolutionX,
                        range: 32...2024,
                        step: 32
                    )
                    ControlStepper(
                        title: "Grid Ny",
                        value: $gridResolutionY,
                        range: 32...2024,
                        step: 32
                    )

                    ControlSlider(
                        title: "Param",
                        value: $param,
                        range: 0.0...1.0,
                        format: .number.precision(.fractionLength(3))
                    )

                    ControlStepper(
                        title: "Substeps",
                        value: $substeps,
                        range: 1...100,
                        step: 1
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary)
                        Text("Grid size changes will rebuild the simulation buffers.")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(theme.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.surfaceSecondary)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(theme.surface)
                        .blur(radius: 16)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(theme.border, lineWidth: 1)
        )
        .shadow(color: theme.shadow, radius: 20, x: 0, y: 12)
    }
}
