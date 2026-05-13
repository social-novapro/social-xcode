//
//  InteractOriginalDesign.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import SwiftUI

struct InteractOriginalDesign: InteractDesignProtocol {
    static let preference: InteractDesignPreference = .original
}

struct InteractOriginalAppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

struct InteractOriginalCardSurfaceModifier: ViewModifier {
    let tone: InteractSectionTone
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let background: Color
    let border: Color

    func body(content: Content) -> some View {
        content
            .background(background)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(tone.borderColor(defaultBorder: border), lineWidth: lineWidth)
            )
    }
}

struct InteractOriginalScreenPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(10)
    }
}

struct InteractOriginalCardListScreenModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if !os(tvOS)
        content
            .listStyle(.plain)
            .listRowSeparator(.hidden)
        #else
        content
            .listStyle(.plain)
        #endif
    }
}

struct InteractOriginalPlainListRowModifier: ViewModifier {
    let rowPadding: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        #if !os(tvOS)
        content
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .padding(rowPadding)
        #else
        content
            .listRowInsets(EdgeInsets())
            .padding(rowPadding)
        #endif
    }
}
