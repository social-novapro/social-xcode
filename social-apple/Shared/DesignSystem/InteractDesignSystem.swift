//
//  InteractDesignSystem.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

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

struct InteractAppBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            InteractDesignColor.backgroundBase(colorScheme: colorScheme)

            LinearGradient(
                colors: gradientStops,
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: colorScheme == .dark ? 360 : 320)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea()
    }

    private var gradientStops: [Color] {
        if colorScheme == .dark {
            return [
                Color.accentColor.opacity(0.22),
                Color.clear
            ]
        }

        return [
            Color.accentColor.opacity(0.18),
            Color.accentColor.opacity(0.08),
            Color.clear
        ]
    }
}

struct InteractCardBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var tone: InteractSectionTone = .normal
    var cornerRadius: CGFloat = 16
    var lineWidth: CGFloat = 1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(cardFill)
            .overlay {
                if colorScheme == .light {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(0.24))
                }
            }
            .overlay {
                if let fillOverlay = tone.fillOverlay(colorScheme: colorScheme) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fillOverlay)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(tone.borderColor(defaultBorder: cardBorder), lineWidth: lineWidth)
            )
            .shadow(
                color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 4
            )
    }

    private var cardFill: AnyShapeStyle {
        if colorScheme == .dark {
            return AnyShapeStyle(Color.white.opacity(0.08))
        }

        return AnyShapeStyle(.regularMaterial)
    }

    private var cardBorder: Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.10)
    }
}

struct InteractConnectedCardSection<Content: View>: View {
    let tone: InteractSectionTone
    let content: Content

    init(
        tone: InteractSectionTone = .normal,
        @ViewBuilder content: () -> Content
    ) {
        self.tone = tone
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(InteractCardBackground(tone: tone))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct InteractConnectedCardRow<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InteractConnectedCardDivider: View {
    var leadingInset: CGFloat = 14

    var body: some View {
        Divider()
            .padding(.leading, leadingInset)
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
        .interactCardSurface()
        .accessibilityElement(children: .combine)
    }
}

private struct InteractCardSurfaceModifier: ViewModifier {
    let tone: InteractSectionTone
    let cornerRadius: CGFloat
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .background(InteractCardBackground(tone: tone, cornerRadius: cornerRadius, lineWidth: lineWidth))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

private enum InteractDesignColor {
    static func backgroundBase(colorScheme: ColorScheme) -> Color {
        #if canImport(UIKit)
        return colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.clear
        #endif
    }
}

extension View {
    func interactAppBackground() -> some View {
        background(InteractAppBackgroundView())
    }

    func interactCardSurface(
        tone: InteractSectionTone = .normal,
        cornerRadius: CGFloat = 16,
        lineWidth: CGFloat = 1
    ) -> some View {
        modifier(InteractCardSurfaceModifier(tone: tone, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }

    func interactScreenPadding(maxWidth: CGFloat = 620) -> some View {
        frame(maxWidth: maxWidth, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    func interactCardListScreen(maxWidth: CGFloat = 620) -> some View {
        #if os(iOS) || os(tvOS)
        listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        #else
        listStyle(.plain)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        #endif
    }

    @ViewBuilder
    func interactPlainListRow(rowPadding: CGFloat = 10) -> some View {
        #if os(iOS) || os(tvOS)
        listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .padding(rowPadding)
        #else
        listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .padding(rowPadding)
        #endif
    }

    @ViewBuilder
    func interactCardListRowStyle(
        top: CGFloat = 6,
        leading: CGFloat = 4,
        bottom: CGFloat = 6,
        trailing: CGFloat = 16
    ) -> some View {
        #if os(iOS) || os(tvOS)
        listRowInsets(EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        #else
        listRowInsets(EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing))
            .listRowBackground(Color.clear)
        #endif
    }

    func interactCardListRowContentPadding() -> some View {
        padding(.vertical, 8)
            .padding(.leading, 14)
            .padding(.trailing, 10)
    }
}
