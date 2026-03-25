//
//  HapticPress.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-14.
//

import Foundation
import CoreHaptics
//import UIKit
import SwiftUI

//func HapticPress() {
//    #if os(iOS)
//    let impactMed = UIImpactFeedbackGenerator(style: .medium)
//    impactMed.impactOccurred()
//
//    print("impact occured")
//    #endif
//}
class HapticPress {
    static let shared = HapticPress()
    
    private init() {
        print(CHHapticEngine.capabilitiesForHardware().supportsHaptics ? "Yes" : "No")
    }

    #if os(iOS)
    func play() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func notify() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    func notifyFail() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    #else
    func play() {
        print("cant press")
    }
    func notify() {
        print("cant press")
    }
    func notifyFail() {
        print("cant press")
    }
    #endif
}
