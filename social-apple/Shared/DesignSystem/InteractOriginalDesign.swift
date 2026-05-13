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
            maxWidth: nil,
            horizontal: 10,
            vertical: 10,
            centersContent: false
        )
    }

    override func listScreenStyle(maxWidth: CGFloat) -> InteractListScreenStyle {
        InteractListScreenStyle(
            maxWidth: nil,
            centersContent: false,
            hidesScrollBackground: true,
            horizontalPadding: 0,
            verticalPadding: 0
        )
    }

    override func listRowStyle(rowPadding: CGFloat) -> InteractListRowStyle {
        InteractListRowStyle(
            insets: EdgeInsets(),
            padding: rowPadding,
            hidesSeparator: true,
            clearBackground: false
        )
    }
}
