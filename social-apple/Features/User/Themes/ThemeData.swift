//
//  ThemeData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-09-02.
//

import Foundation
import SwiftUI

class ThemeData: ObservableObject {
    var devMode: DevModeData
    
    // client.themeData.mainBackground
    @Published var mainBackground: Color = .clear
    // client.themeData.greenBackground
    @Published var greenBackground: Color = .clear
    // client.themeData.blueBackground
    @Published var blueBackground: Color = .clear

    
    init(devMode: DevModeData) {
        self.devMode = devMode
        updateThemes(devMode: devMode)
    }
    
    func updateThemes(devMode: DevModeData) {
        self.devMode = devMode
        
        if (devMode.isEnabled) {
            mainBackground = .red
            greenBackground = .green
            blueBackground = .blue
        } else {
            mainBackground = .clear
            greenBackground = .clear
            blueBackground = .clear
        }
        
    }
}

