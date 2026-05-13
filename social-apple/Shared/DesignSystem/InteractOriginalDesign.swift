//
//  InteractOriginalDesign.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import SwiftUI

final class InteractOriginalDesign: InteractAppDesign {
    init() {
        super.init(preference: .original)
    }

    override var connectedDividerVisible: Bool { false }
    override var defaultCardCornerRadius: CGFloat { 20 }
    override var defaultCardLineWidth: CGFloat { 3 }
    override var connectedCardCornerRadius: CGFloat { 20 }
    override var connectedCardLineWidth: CGFloat { 3 }

    override func appBackgroundStyle(colorScheme: ColorScheme) -> InteractAppBackgroundStyle {
        InteractAppBackgroundStyle(
            baseColor: .clear,
            gradientColors: [],
            gradientHeight: 0,
            ignoresSafeArea: false
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
            insets: EdgeInsets(top: rowPadding, leading: 4, bottom: rowPadding, trailing: 16),
            padding: 0,
            hidesSeparator: true,
            clearBackground: true
        )
    }
}
