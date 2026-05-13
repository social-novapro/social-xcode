//
//  InteractNewDesign.swift
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

final class InteractNewDesign: InteractAppDesign {
    init() {
        super.init(preference: .new)
    }

    override var connectedDividerVisible: Bool { true }
    override var defaultCardCornerRadius: CGFloat { 16 }
    override var defaultCardLineWidth: CGFloat { 1 }
    override var connectedCardCornerRadius: CGFloat { 16 }
    override var connectedCardLineWidth: CGFloat { 1 }
    override var connectedSectionContentPadding: CGFloat? { nil }

    override func appBackgroundStyle(colorScheme: ColorScheme) -> InteractAppBackgroundStyle {
        InteractAppBackgroundStyle(
            baseColor: backgroundBase(colorScheme: colorScheme),
            gradientColors: gradientStops(colorScheme: colorScheme),
            gradientHeight: colorScheme == .dark ? 360 : 320,
            ignoresSafeArea: true
        )
    }

    override func surfaceStyle(
        tone: InteractSectionTone,
        colorScheme: ColorScheme,
        cornerRadius: CGFloat,
        lineWidth: CGFloat,
        originalBackground: Color,
        originalBorder: Color
    ) -> InteractSurfaceStyle {
        InteractSurfaceStyle(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            fill: cardFill(colorScheme: colorScheme),
            lightOverlay: colorScheme == .light ? Color.white.opacity(0.24) : nil,
            toneOverlay: toneFillOverlay(tone: tone, colorScheme: colorScheme),
            borderColor: toneBorderColor(tone: tone, defaultBorder: cardBorder(colorScheme: colorScheme)),
            shadow: colorScheme == .dark
                ? nil
                : InteractShadowStyle(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4),
            clipsToShape: true
        )
    }

    override func connectedSectionStyle(
        tone: InteractSectionTone,
        colorScheme: ColorScheme
    ) -> InteractSurfaceStyle {
        surfaceStyle(
            tone: tone,
            colorScheme: colorScheme,
            cornerRadius: connectedCardCornerRadius,
            lineWidth: connectedCardLineWidth,
            originalBackground: .clear,
            originalBorder: cardBorder(colorScheme: colorScheme)
        )
    }

    override func connectedRowStyle() -> InteractConnectedRowStyle {
        InteractConnectedRowStyle(
            padding: EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14),
            appliesPadding: true
        )
    }

    override func screenPaddingStyle(maxWidth: CGFloat) -> InteractScreenPaddingStyle {
        InteractScreenPaddingStyle(
            maxWidth: maxWidth,
            horizontal: 16,
            vertical: 12,
            centersContent: true
        )
    }

    override func listScreenStyle(maxWidth: CGFloat) -> InteractListScreenStyle {
        InteractListScreenStyle(
            maxWidth: maxWidth,
            centersContent: true,
            hidesScrollBackground: true,
            horizontalPadding: 6,
            verticalPadding: 12
        )
    }

    override func listRowStyle(rowPadding: CGFloat) -> InteractListRowStyle {
        InteractListRowStyle(
            insets: EdgeInsets(),
            padding: rowPadding,
            hidesSeparator: true,
            clearBackground: true
        )
    }

    override func inputSurfaceStyle(colorScheme: ColorScheme) -> InteractSurfaceStyle {
        surfaceStyle(
            tone: .normal,
            colorScheme: colorScheme,
            cornerRadius: 14,
            lineWidth: 1,
            originalBackground: .clear,
            originalBorder: cardBorder(colorScheme: colorScheme)
        )
    }

    override func floatingSurfaceStyle(
        tone: InteractSectionTone,
        colorScheme: ColorScheme
    ) -> InteractFloatingSurfaceStyle {
        InteractFloatingSurfaceStyle(
            fill: colorScheme == .dark
                ? AnyShapeStyle(Color.white.opacity(0.08))
                : AnyShapeStyle(.regularMaterial),
            borderColor: toneBorderColor(tone: tone, defaultBorder: cardBorder(colorScheme: colorScheme)),
            lineWidth: 1,
            shadow: colorScheme == .dark
                ? nil
                : InteractShadowStyle(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
        )
    }

    private func backgroundBase(colorScheme: ColorScheme) -> Color {
        #if canImport(UIKit)
        return colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.clear
        #endif
    }

    private func gradientStops(colorScheme: ColorScheme) -> [Color] {
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

    private func cardFill(colorScheme: ColorScheme) -> AnyShapeStyle {
        if colorScheme == .dark {
            return AnyShapeStyle(Color.white.opacity(0.08))
        }

        return AnyShapeStyle(.regularMaterial)
    }

    private func cardBorder(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.10)
    }
}
