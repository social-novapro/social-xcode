//
//  InteractDesignProtocol.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import SwiftUI

enum InteractDesignPreference: String, CaseIterable, Identifiable, Codable {
    case original
    case new

    static let defaultPreference: InteractDesignPreference = .new

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
}

struct InteractShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct InteractAppBackgroundStyle {
    let baseColor: Color
    let gradientColors: [Color]
    let gradientHeight: CGFloat
    let ignoresSafeArea: Bool
}

struct InteractSurfaceStyle {
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let fill: AnyShapeStyle
    let lightOverlay: Color?
    let toneOverlay: Color?
    let borderColor: Color
    let shadow: InteractShadowStyle?
    let clipsToShape: Bool
}

struct InteractScreenPaddingStyle {
    let maxWidth: CGFloat?
    let horizontal: CGFloat
    let vertical: CGFloat
    let centersContent: Bool
}

struct InteractListScreenStyle {
    let maxWidth: CGFloat?
    let centersContent: Bool
    let hidesScrollBackground: Bool
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
}

struct InteractListRowStyle {
    let insets: EdgeInsets
    let padding: CGFloat
    let hidesSeparator: Bool
    let clearBackground: Bool
}

struct InteractConnectedRowStyle {
    let padding: EdgeInsets
    let appliesPadding: Bool
}

struct InteractFloatingSurfaceStyle {
    let fill: AnyShapeStyle
    let borderColor: Color
    let lineWidth: CGFloat
    let shadow: InteractShadowStyle?
}

class InteractAppDesign {
    let preference: InteractDesignPreference

    init(preference: InteractDesignPreference) {
        self.preference = preference
    }

    var connectedDividerVisible: Bool { false }
    var sectionHeaderHorizontalPadding: CGFloat { 4 }
    var defaultCardCornerRadius: CGFloat { 20 }
    var defaultCardLineWidth: CGFloat { 3 }
    var connectedCardCornerRadius: CGFloat { 20 }
    var connectedCardLineWidth: CGFloat { 3 }
    var connectedSectionContentPadding: CGFloat? { 15 }
    var customTabBarBottomContentInset: CGFloat { 80 }

    func toneBorderColor(
        tone: InteractSectionTone,
        defaultBorder: Color
    ) -> Color {
        switch tone {
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

    func toneFillOverlay(
        tone: InteractSectionTone,
        colorScheme: ColorScheme
    ) -> Color? {
        switch tone {
        case .normal, .owner:
            return nil
        case .current, .selected:
            return Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12)
        case .destructive:
            return Color.red.opacity(colorScheme == .dark ? 0.18 : 0.12)
        case .custom(let color):
            return color.opacity(colorScheme == .dark ? 0.18 : 0.12)
        }
    }

    func appBackgroundStyle(colorScheme: ColorScheme) -> InteractAppBackgroundStyle {
        InteractAppBackgroundStyle(
            baseColor: .clear,
            gradientColors: [],
            gradientHeight: 0,
            ignoresSafeArea: false
        )
    }

    func surfaceStyle(
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
            fill: AnyShapeStyle(originalBackground),
            lightOverlay: nil,
            toneOverlay: nil,
            borderColor: toneBorderColor(tone: tone, defaultBorder: originalBorder),
            shadow: nil,
            clipsToShape: false
        )
    }

    func connectedSectionStyle(
        tone: InteractSectionTone,
        colorScheme: ColorScheme
    ) -> InteractSurfaceStyle {
        surfaceStyle(
            tone: tone,
            colorScheme: colorScheme,
            cornerRadius: connectedCardCornerRadius,
            lineWidth: connectedCardLineWidth,
            originalBackground: .clear,
            originalBorder: .accentColor
        )
    }

    func connectedRowStyle() -> InteractConnectedRowStyle {
        InteractConnectedRowStyle(
            padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            appliesPadding: false
        )
    }

    func screenPaddingStyle(maxWidth: CGFloat) -> InteractScreenPaddingStyle {
        InteractScreenPaddingStyle(
            maxWidth: maxWidth,
            horizontal: 16,
            vertical: 12,
            centersContent: true
        )
    }

    func listScreenStyle(maxWidth: CGFloat) -> InteractListScreenStyle {
        InteractListScreenStyle(
            maxWidth: maxWidth,
            centersContent: true,
            hidesScrollBackground: true,
            horizontalPadding: 6,
            verticalPadding: 12
        )
    }

    func listRowStyle(rowPadding: CGFloat) -> InteractListRowStyle {
        InteractListRowStyle(
            insets: EdgeInsets(top: rowPadding, leading: 4, bottom: rowPadding, trailing: 16),
            padding: 0,
            hidesSeparator: true,
            clearBackground: true
        )
    }

    func inputSurfaceStyle(colorScheme: ColorScheme) -> InteractSurfaceStyle {
        surfaceStyle(
            tone: .normal,
            colorScheme: colorScheme,
            cornerRadius: defaultCardCornerRadius,
            lineWidth: defaultCardLineWidth,
            originalBackground: .clear,
            originalBorder: .accentColor
        )
    }

    func floatingSurfaceStyle(
        tone: InteractSectionTone,
        colorScheme: ColorScheme
    ) -> InteractFloatingSurfaceStyle {
        InteractFloatingSurfaceStyle(
            fill: AnyShapeStyle(floatingSurfaceFill(colorScheme: colorScheme)),
            borderColor: toneBorderColor(tone: tone, defaultBorder: .accentColor),
            lineWidth: 2,
            shadow: nil
        )
    }
    
    func floatingSurfaceFill(colorScheme: ColorScheme) -> Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemBackground).opacity(0.96)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor).opacity(0.96)
        #else
        return Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.08)
        #endif
    }
}

enum InteractDesignRegistry {
    private static let originalDesign = InteractOriginalDesign()
    private static let newDesign = InteractNewDesign()

    static func design(for preference: InteractDesignPreference) -> InteractAppDesign {
        switch preference {
        case .original:
            return originalDesign
        case .new:
            return newDesign
        }
    }
}

private struct InteractDesignKey: EnvironmentKey {
    static let defaultValue: InteractAppDesign = InteractDesignRegistry.design(for: InteractDesignPreference.defaultPreference)
}

private struct InteractCustomTabBarReserveActiveKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var interactDesign: InteractAppDesign {
        get { self[InteractDesignKey.self] }
        set { self[InteractDesignKey.self] = newValue }
    }

    var customTabBarReserveIsActive: Bool {
        get { self[InteractCustomTabBarReserveActiveKey.self] }
        set { self[InteractCustomTabBarReserveActiveKey.self] = newValue }
    }
}
