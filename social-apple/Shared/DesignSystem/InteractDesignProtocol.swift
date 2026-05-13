//
//  InteractDesignProtocol.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import SwiftUI

protocol InteractDesignProtocol {
    static var preference: InteractDesignPreference { get }
}

enum InteractDesignPreference: String, CaseIterable, Identifiable, Codable {
    case original
    case new

    var id: String { rawValue }

    var title: String {
        switch self {
        case .original:
            return "Original"
        case .new:
            return "New"
        }
    }
}

enum InteractSectionTone {
    case normal
    case owner
    case current
    case selected
    case destructive
    case custom(Color)

    func borderColor(defaultBorder: Color) -> Color {
        switch self {
        case .normal:
            return defaultBorder
        case .owner, .current, .selected:
            return .accentColor
        case .destructive:
            return .red
        case .custom(let color):
            return color
        }
    }

    func fillOverlay(colorScheme: ColorScheme) -> Color? {
        let opacity = colorScheme == .dark ? 0.18 : 0.12

        switch self {
        case .normal:
            return nil
        case .owner, .current, .selected:
            return Color.accentColor.opacity(opacity)
        case .destructive:
            return Color.red.opacity(opacity)
        case .custom(let color):
            return color.opacity(opacity)
        }
    }
}

struct InteractConnectedCardSection<Content: View>: View {
    let design: InteractDesignPreference
    let tone: InteractSectionTone
    let content: Content

    init(
        design: InteractDesignPreference,
        tone: InteractSectionTone = .normal,
        @ViewBuilder content: () -> Content
    ) {
        self.design = design
        self.tone = tone
        self.content = content()
    }

    var body: some View {
        switch design {
        case .original:
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(tone.borderColor(defaultBorder: .accentColor), lineWidth: 3)
            )
        case .new:
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(InteractNewCardBackground(tone: tone))
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct InteractConnectedCardRow<Content: View>: View {
    let design: InteractDesignPreference
    let content: Content

    init(
        design: InteractDesignPreference,
        @ViewBuilder content: () -> Content
    ) {
        self.design = design
        self.content = content()
    }

    var body: some View {
        switch design {
        case .original:
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        case .new:
            content
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct InteractConnectedCardDivider: View {
    let design: InteractDesignPreference
    var leadingInset: CGFloat = 14

    var body: some View {
        switch design {
        case .original:
            EmptyView()
        case .new:
            Divider()
                .padding(.leading, leadingInset)
        }
    }
}

struct InteractSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .accessibilityAddTraits(.isHeader)
    }
}

struct InteractEmptyStateView: View {
    let design: InteractDesignPreference
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(14)
        .interactCardSurface(design: design)
        .accessibilityElement(children: .combine)
    }
}

extension View {
    func interactAppBackground(design: InteractDesignPreference) -> some View {
        modifier(InteractAppBackgroundModifier(design: design))
    }

    func interactCardSurface(
        design: InteractDesignPreference,
        tone: InteractSectionTone = .normal,
        cornerRadius: CGFloat = 16,
        lineWidth: CGFloat = 1,
        originalBackground: Color = .clear,
        originalBorder: Color = .gray
    ) -> some View {
        modifier(
            InteractCardSurfaceModifier(
                design: design,
                tone: tone,
                cornerRadius: cornerRadius,
                lineWidth: lineWidth,
                originalBackground: originalBackground,
                originalBorder: originalBorder
            )
        )
    }

    func interactScreenPadding(
        design: InteractDesignPreference,
        maxWidth: CGFloat = 620
    ) -> some View {
        modifier(InteractScreenPaddingModifier(design: design, maxWidth: maxWidth))
    }

    func interactCardListScreen(
        design: InteractDesignPreference,
        maxWidth: CGFloat = 620
    ) -> some View {
        modifier(InteractCardListScreenModifier(design: design, maxWidth: maxWidth))
    }

    func interactPlainListRow(
        design: InteractDesignPreference,
        rowPadding: CGFloat = 10
    ) -> some View {
        modifier(InteractPlainListRowModifier(design: design, rowPadding: rowPadding))
    }
}

private struct InteractAppBackgroundModifier: ViewModifier {
    let design: InteractDesignPreference

    @ViewBuilder
    func body(content: Content) -> some View {
        switch design {
        case .original:
            content.modifier(InteractOriginalAppBackgroundModifier())
        case .new:
            content.modifier(InteractNewAppBackgroundModifier())
        }
    }
}

private struct InteractCardSurfaceModifier: ViewModifier {
    let design: InteractDesignPreference
    let tone: InteractSectionTone
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let originalBackground: Color
    let originalBorder: Color

    @ViewBuilder
    func body(content: Content) -> some View {
        switch design {
        case .original:
            content.modifier(
                InteractOriginalCardSurfaceModifier(
                    tone: tone,
                    cornerRadius: cornerRadius,
                    lineWidth: lineWidth,
                    background: originalBackground,
                    border: originalBorder
                )
            )
        case .new:
            content.modifier(
                InteractNewCardSurfaceModifier(
                    tone: tone,
                    cornerRadius: cornerRadius,
                    lineWidth: lineWidth
                )
            )
        }
    }
}

private struct InteractScreenPaddingModifier: ViewModifier {
    let design: InteractDesignPreference
    let maxWidth: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        switch design {
        case .original:
            content.modifier(InteractOriginalScreenPaddingModifier())
        case .new:
            content.modifier(InteractNewScreenPaddingModifier(maxWidth: maxWidth))
        }
    }
}

private struct InteractCardListScreenModifier: ViewModifier {
    let design: InteractDesignPreference
    let maxWidth: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        switch design {
        case .original:
            content.modifier(InteractOriginalCardListScreenModifier())
        case .new:
            content.modifier(InteractNewCardListScreenModifier(maxWidth: maxWidth))
        }
    }
}

private struct InteractPlainListRowModifier: ViewModifier {
    let design: InteractDesignPreference
    let rowPadding: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        switch design {
        case .original:
            content.modifier(InteractOriginalPlainListRowModifier(rowPadding: rowPadding))
        case .new:
            content.modifier(InteractNewPlainListRowModifier(rowPadding: rowPadding))
        }
    }
}
