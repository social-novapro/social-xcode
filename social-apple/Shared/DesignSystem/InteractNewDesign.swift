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

struct InteractNewDesign: InteractDesignProtocol {
    static let preference: InteractDesignPreference = .new
}

struct InteractNewAppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(InteractNewAppBackgroundView())
    }
}

struct InteractNewAppBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            backgroundBase

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

    private var backgroundBase: Color {
        #if canImport(UIKit)
        return colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.clear
        #endif
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

struct InteractNewCardBackground: View {
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

struct InteractNewCardSurfaceModifier: ViewModifier {
    let tone: InteractSectionTone
    let cornerRadius: CGFloat
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                InteractNewCardBackground(
                    tone: tone,
                    cornerRadius: cornerRadius,
                    lineWidth: lineWidth
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct InteractNewScreenPaddingModifier: ViewModifier {
    let maxWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct InteractNewCardListScreenModifier: ViewModifier {
    let maxWidth: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS)
        content
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        #else
        content
            .listStyle(.plain)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        #endif
    }
}

struct InteractNewPlainListRowModifier: ViewModifier {
    let rowPadding: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS)
        content
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .padding(rowPadding)
        #else
        content
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .padding(rowPadding)
        #endif
    }
}
