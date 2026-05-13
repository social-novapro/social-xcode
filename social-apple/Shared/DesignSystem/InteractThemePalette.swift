//
//  InteractThemePalette.swift
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

struct InteractColourTheme: Codable {
    var id: String?
    var posts: String?
    var fontPostsContent: String?
    var fontPostsAction: String?
    var background: String?
    var navigation: String?
    var fontNavigation: String?
    var navSecondary: String?
    var fontNavSecondary: String?
    var menu: String?
    var fontMenu: String?
    var menuButton: String?
    var fontMenuButton: String?
    var fontH1: String?
    var fontOtherUser: String?
    var fontOwnUser: String?
    var fontPSecondary: String?

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case posts
        case fontPostsContent = "font_posts_content"
        case fontPostsAction = "font_posts_action"
        case background
        case navigation
        case fontNavigation = "font_navigation"
        case navSecondary
        case fontNavSecondary = "font_navSecondary"
        case menu
        case fontMenu = "font_menu"
        case menuButton
        case fontMenuButton = "font_menuButton"
        case fontH1 = "font_h1"
        case fontOtherUser = "font_otherUser"
        case fontOwnUser = "font_ownUser"
        case fontPSecondary = "font_p_secondary"
    }
}

struct InteractThemePalette {
    let background: Color
    let navigation: Color
    let secondaryNavigation: Color
    let menu: Color
    let menuButton: Color
    let postSurface: Color
    let primaryText: Color
    let secondaryText: Color
    let headerText: Color
    let postText: Color
    let postActionText: Color
    let ownUserText: Color
    let otherUserText: Color

    static func resolved(
        from colourTheme: InteractColourTheme?,
        colorScheme: ColorScheme
    ) -> InteractThemePalette {
        let defaultPalette = InteractThemePalette.defaultPalette(colorScheme: colorScheme)

        return InteractThemePalette(
            background: Color(interactHex: colourTheme?.background) ?? defaultPalette.background,
            navigation: Color(interactHex: colourTheme?.navigation) ?? defaultPalette.navigation,
            secondaryNavigation: Color(interactHex: colourTheme?.navSecondary) ?? defaultPalette.secondaryNavigation,
            menu: Color(interactHex: colourTheme?.menu) ?? defaultPalette.menu,
            menuButton: Color(interactHex: colourTheme?.menuButton) ?? defaultPalette.menuButton,
            postSurface: Color(interactHex: colourTheme?.posts) ?? defaultPalette.postSurface,
            primaryText: Color(interactHex: colourTheme?.fontMenu) ?? defaultPalette.primaryText,
            secondaryText: Color(interactHex: colourTheme?.fontPSecondary) ?? defaultPalette.secondaryText,
            headerText: Color(interactHex: colourTheme?.fontH1) ?? defaultPalette.headerText,
            postText: Color(interactHex: colourTheme?.fontPostsContent) ?? defaultPalette.postText,
            postActionText: Color(interactHex: colourTheme?.fontPostsAction) ?? defaultPalette.postActionText,
            ownUserText: Color(interactHex: colourTheme?.fontOwnUser) ?? defaultPalette.ownUserText,
            otherUserText: Color(interactHex: colourTheme?.fontOtherUser) ?? defaultPalette.otherUserText
        )
    }

    private static func defaultPalette(colorScheme: ColorScheme) -> InteractThemePalette {
        InteractThemePalette(
            background: platformGroupedBackground(colorScheme: colorScheme),
            navigation: platformSecondaryBackground(colorScheme: colorScheme),
            secondaryNavigation: platformSecondaryBackground(colorScheme: colorScheme),
            menu: platformSecondaryBackground(colorScheme: colorScheme),
            menuButton: Color.accentColor,
            postSurface: platformSecondaryBackground(colorScheme: colorScheme),
            primaryText: .primary,
            secondaryText: .secondary,
            headerText: .primary,
            postText: .primary,
            postActionText: .secondary,
            ownUserText: .accentColor,
            otherUserText: .secondary
        )
    }

    private static func platformGroupedBackground(colorScheme: ColorScheme) -> Color {
        #if canImport(UIKit)
        return colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.clear
        #endif
    }

    private static func platformSecondaryBackground(colorScheme: ColorScheme) -> Color {
        #if canImport(UIKit)
        return colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.secondarySystemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.clear
        #endif
    }
}

extension Color {
    init?(interactHex hexString: String?) {
        guard var hex = hexString?.trimmingCharacters(in: .whitespacesAndNewlines),
              hex.isEmpty == false else {
            return nil
        }

        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        if hex.count == 3 {
            hex = hex.map { String(repeating: String($0), count: 2) }.joined()
        }

        guard hex.count == 6,
              let value = UInt64(hex, radix: 16) else {
            return nil
        }

        self.init(
            .sRGB,
            red: Double((value & 0xFF0000) >> 16) / 255,
            green: Double((value & 0x00FF00) >> 8) / 255,
            blue: Double(value & 0x0000FF) / 255,
            opacity: 1
        )
    }
}
