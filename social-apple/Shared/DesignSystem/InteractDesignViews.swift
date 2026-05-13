//
//  InteractDesignViews.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import SwiftUI

struct InteractAppBackgroundView: View {
    let style: InteractAppBackgroundStyle

    var body: some View {
        if style.ignoresSafeArea {
            background.ignoresSafeArea()
        } else {
            background
        }
    }

    private var background: some View {
        ZStack(alignment: .top) {
            style.baseColor

            if !style.gradientColors.isEmpty {
                LinearGradient(
                    colors: style.gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: style.gradientHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

struct InteractSurfaceBackground: View {
    let style: InteractSurfaceStyle

    var body: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
            .fill(style.fill)
            .overlay {
                if let lightOverlay = style.lightOverlay {
                    RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                        .fill(lightOverlay)
                }
            }
            .overlay {
                if let toneOverlay = style.toneOverlay {
                    RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                        .fill(toneOverlay)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                    .stroke(style.borderColor, lineWidth: style.lineWidth)
            )
            .shadow(
                color: style.shadow?.color ?? .clear,
                radius: style.shadow?.radius ?? 0,
                x: style.shadow?.x ?? 0,
                y: style.shadow?.y ?? 0
            )
    }
}

struct InteractConnectedCardSection<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.interactDesign) private var environmentDesign
    let designOverride: InteractAppDesign?
    let tone: InteractSectionTone
    let content: Content

    init(
        design: InteractDesignPreference? = nil,
        tone: InteractSectionTone = .normal,
        @ViewBuilder content: () -> Content
    ) {
        designOverride = design.map { InteractDesignRegistry.design(for: $0) }
        self.tone = tone
        self.content = content()
    }

    init(
        design: InteractAppDesign?,
        tone: InteractSectionTone = .normal,
        @ViewBuilder content: () -> Content
    ) {
        designOverride = design
        self.tone = tone
        self.content = content()
    }

    var body: some View {
        let design = currentDesign
        let style = design.connectedSectionStyle(tone: tone, colorScheme: colorScheme)

        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .modifier(InteractOptionalPaddingModifier(padding: design.connectedSectionContentPadding))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(InteractSurfaceBackground(style: style))
        .contentShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
    }

    private var currentDesign: InteractAppDesign {
        designOverride ?? environmentDesign
    }
}

struct InteractConnectedCardRow<Content: View>: View {
    @Environment(\.interactDesign) private var environmentDesign
    let designOverride: InteractAppDesign?
    let content: Content

    init(
        design: InteractDesignPreference? = nil,
        @ViewBuilder content: () -> Content
    ) {
        designOverride = design.map { InteractDesignRegistry.design(for: $0) }
        self.content = content()
    }

    init(
        design: InteractAppDesign?,
        @ViewBuilder content: () -> Content
    ) {
        designOverride = design
        self.content = content()
    }

    var body: some View {
        let style = currentDesign.connectedRowStyle()

        content
            .modifier(InteractOptionalEdgePaddingModifier(style: style))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var currentDesign: InteractAppDesign {
        designOverride ?? environmentDesign
    }
}

struct InteractConnectedCardDivider: View {
    @Environment(\.interactDesign) private var environmentDesign
    let designOverride: InteractAppDesign?
    var leadingInset: CGFloat = 14

    init(
        design: InteractDesignPreference? = nil,
        leadingInset: CGFloat = 14
    ) {
        designOverride = design.map { InteractDesignRegistry.design(for: $0) }
        self.leadingInset = leadingInset
    }

    init(
        design: InteractAppDesign?,
        leadingInset: CGFloat = 14
    ) {
        designOverride = design
        self.leadingInset = leadingInset
    }

    var body: some View {
        if currentDesign.connectedDividerVisible {
            Divider()
                .padding(.leading, leadingInset)
        }
    }

    private var currentDesign: InteractAppDesign {
        designOverride ?? environmentDesign
    }
}

struct InteractSectionHeader: View {
    @Environment(\.interactDesign) private var design
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
        .padding(.horizontal, design.sectionHeaderHorizontalPadding)
        .accessibilityAddTraits(.isHeader)
    }
}

struct InteractEmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String

    init(
        design: InteractDesignPreference? = nil,
        title: String,
        systemImage: String,
        message: String
    ) {
        self.title = title
        self.systemImage = systemImage
        self.message = message
    }

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

struct InteractSettingsRowLabel: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    var showsChevron = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct InteractActionRow: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    var role: ButtonRole? = nil
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            InteractConnectedCardRow {
                InteractSettingsRowLabel(
                    title: title,
                    subtitle: subtitle,
                    systemImage: systemImage,
                    showsChevron: false
                )
            }
        }
        .buttonStyle(.plain)
    }
}

struct InteractNavigationRow<Destination: View>: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    let destination: Destination

    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            InteractConnectedCardRow {
                InteractSettingsRowLabel(
                    title: title,
                    subtitle: subtitle,
                    systemImage: systemImage
                )
            }
        }
        .buttonStyle(.plain)
    }
}

struct InteractStatusBanner<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.interactDesign) private var design
    var tone: InteractSectionTone = .normal
    let content: Content

    init(
        tone: InteractSectionTone = .normal,
        @ViewBuilder content: () -> Content
    ) {
        self.tone = tone
        self.content = content()
    }

    var body: some View {
        let style = design.floatingSurfaceStyle(tone: tone, colorScheme: colorScheme)

        content
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(style.fill)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(style.borderColor, lineWidth: style.lineWidth)
            )
            .shadow(
                color: style.shadow?.color ?? .clear,
                radius: style.shadow?.radius ?? 0,
                x: style.shadow?.x ?? 0,
                y: style.shadow?.y ?? 0
            )
            .contentShape(Capsule(style: .continuous))
    }
}

extension View {
    func interactDesign(_ design: InteractAppDesign) -> some View {
        environment(\.interactDesign, design)
    }

    func interactDesignPreference(_ design: InteractDesignPreference) -> some View {
        interactDesign(InteractDesignRegistry.design(for: design))
    }

    func interactAppBackground(design: InteractDesignPreference? = nil) -> some View {
        modifier(
            InteractAppBackgroundModifier(
                designOverride: design.map { InteractDesignRegistry.design(for: $0) }
            )
        )
    }

    func interactCardSurface(
        design: InteractDesignPreference? = nil,
        tone: InteractSectionTone = .normal,
        cornerRadius: CGFloat = 16,
        lineWidth: CGFloat = 1,
        originalBackground: Color = .clear,
        originalBorder: Color = .gray
    ) -> some View {
        modifier(
            InteractCardSurfaceModifier(
                designOverride: design.map { InteractDesignRegistry.design(for: $0) },
                tone: tone,
                cornerRadius: cornerRadius,
                lineWidth: lineWidth,
                originalBackground: originalBackground,
                originalBorder: originalBorder
            )
        )
    }

    func interactScreenPadding(
        design: InteractDesignPreference? = nil,
        maxWidth: CGFloat = 600
    ) -> some View {
        modifier(
            InteractScreenPaddingModifier(
                designOverride: design.map { InteractDesignRegistry.design(for: $0) },
                maxWidth: maxWidth
            )
        )
    }

    func interactCardListScreen(
        design: InteractDesignPreference? = nil,
        maxWidth: CGFloat = 620
    ) -> some View {
        modifier(
            InteractCardListScreenModifier(
                designOverride: design.map { InteractDesignRegistry.design(for: $0) },
                maxWidth: maxWidth
            )
        )
    }

    func interactPlainListRow(
        design: InteractDesignPreference? = nil,
        rowPadding: CGFloat = 6
    ) -> some View {
        modifier(
            InteractPlainListRowModifier(
                designOverride: design.map { InteractDesignRegistry.design(for: $0) },
                rowPadding: rowPadding
            )
        )
    }

    func interactInputSurface() -> some View {
        modifier(InteractInputSurfaceModifier())
    }

    func interactFloatingSurface(tone: InteractSectionTone = .normal) -> some View {
        modifier(InteractFloatingSurfaceModifier(tone: tone))
    }
}

private struct InteractOptionalPaddingModifier: ViewModifier {
    let padding: CGFloat?

    func body(content: Content) -> some View {
        if let padding {
            content.padding(padding)
        } else {
            content
        }
    }
}

private struct InteractOptionalEdgePaddingModifier: ViewModifier {
    let style: InteractConnectedRowStyle

    func body(content: Content) -> some View {
        if style.appliesPadding {
            content.padding(style.padding)
        } else {
            content
        }
    }
}

private struct InteractAppBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.interactDesign) private var environmentDesign
    let designOverride: InteractAppDesign?

    func body(content: Content) -> some View {
        let design = designOverride ?? environmentDesign
        let style = design.appBackgroundStyle(colorScheme: colorScheme)

        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(InteractAppBackgroundView(style: style))
    }
}

private struct InteractCardSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.interactDesign) private var environmentDesign
    let designOverride: InteractAppDesign?
    let tone: InteractSectionTone
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let originalBackground: Color
    let originalBorder: Color

    @ViewBuilder
    func body(content: Content) -> some View {
        let design = designOverride ?? environmentDesign
        let style = design.surfaceStyle(
            tone: tone,
            colorScheme: colorScheme,
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            originalBackground: originalBackground,
            originalBorder: originalBorder
        )

        if style.clipsToShape {
            content
                .background(InteractSurfaceBackground(style: style))
                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
        } else {
            content
                .background(InteractSurfaceBackground(style: style))
                .cornerRadius(style.cornerRadius)
        }
    }
}

private struct InteractScreenPaddingModifier: ViewModifier {
    @Environment(\.interactDesign) private var environmentDesign
    let designOverride: InteractAppDesign?
    let maxWidth: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        let style = (designOverride ?? environmentDesign).screenPaddingStyle(maxWidth: maxWidth)

        if style.centersContent, let maxWidth = style.maxWidth {
            content
                .frame(maxWidth: maxWidth, alignment: .leading)
                .padding(.horizontal, style.horizontal)
                .padding(.vertical, style.vertical)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            content
                .padding(.horizontal, style.horizontal)
                .padding(.vertical, style.vertical)
        }
    }
}

private struct InteractCardListScreenModifier: ViewModifier {
    @Environment(\.interactDesign) private var environmentDesign
    let designOverride: InteractAppDesign?
    let maxWidth: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        let style = (designOverride ?? environmentDesign).listScreenStyle(maxWidth: maxWidth)

        #if os(iOS) || os(tvOS)
        if style.hidesScrollBackground {
            styledList(content)
                .scrollContentBackground(.hidden)
        } else {
            styledList(content)
        }
        #else
        styledList(content)
        #endif
    }

    @ViewBuilder
    private func styledList(_ content: Content) -> some View {
        let style = (designOverride ?? environmentDesign).listScreenStyle(maxWidth: maxWidth)

        if style.centersContent, let maxWidth = style.maxWidth {
            applyVerticalListContentMargins(
                content
                .listStyle(.plain)
                .frame(maxWidth: maxWidth, alignment: .leading)
                .padding(.horizontal, style.horizontalPadding),
                style: style
            )
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
            applyVerticalListContentMargins(content.listStyle(.plain), style: style)
        }
    }

    @ViewBuilder
    private func applyVerticalListContentMargins<V: View>(_ view: V, style: InteractListScreenStyle) -> some View {
        #if os(iOS) || os(tvOS)
        if #available(iOS 17.0, tvOS 17.0, *) {
            view
                .contentMargins(.top, style.verticalPadding, for: .scrollContent)
                .contentMargins(.bottom, style.verticalPadding, for: .scrollContent)
        } else {
            view
        }
        #elseif os(macOS)
        if #available(macOS 14.0, *) {
            view
                .contentMargins(.top, style.verticalPadding, for: .scrollContent)
                .contentMargins(.bottom, style.verticalPadding, for: .scrollContent)
        } else {
            view
        }
        #else
        view
        #endif
    }
}

private struct InteractPlainListRowModifier: ViewModifier {
    @Environment(\.interactDesign) private var environmentDesign
    let designOverride: InteractAppDesign?
    let rowPadding: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        let style = (designOverride ?? environmentDesign).listRowStyle(rowPadding: rowPadding)

        #if !os(tvOS)
        if style.clearBackground {
            content
                .listRowInsets(style.insets)
                .listRowSeparator(style.hidesSeparator ? .hidden : .visible)
                .listRowBackground(Color.clear)
                .padding(style.padding)
        } else {
            content
                .listRowInsets(style.insets)
                .listRowSeparator(style.hidesSeparator ? .hidden : .visible)
                .padding(style.padding)
        }
        #else
        if style.clearBackground {
            content
                .listRowInsets(style.insets)
                .listRowBackground(Color.clear)
                .padding(style.padding)
        } else {
            content
                .listRowInsets(style.insets)
                .padding(style.padding)
        }
        #endif
    }
}

private struct InteractInputSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.interactDesign) private var design

    func body(content: Content) -> some View {
        let style = design.inputSurfaceStyle(colorScheme: colorScheme)

        content
            .padding(15)
            .background(InteractSurfaceBackground(style: style))
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
    }
}

private struct InteractFloatingSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.interactDesign) private var design
    let tone: InteractSectionTone

    func body(content: Content) -> some View {
        let style = design.floatingSurfaceStyle(tone: tone, colorScheme: colorScheme)

        content
            .background(
                Capsule(style: .continuous)
                    .fill(style.fill)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(style.borderColor, lineWidth: style.lineWidth)
            )
            .shadow(
                color: style.shadow?.color ?? .clear,
                radius: style.shadow?.radius ?? 0,
                x: style.shadow?.x ?? 0,
                y: style.shadow?.y ?? 0
            )
            .contentShape(Capsule(style: .continuous))
    }
}
