//
//  HapticHandler.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-14.
//

import Foundation
import CoreData

class HapticModeHandler {
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "social_apple")
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
    }
    
    func saveHapticMode(hapticModeData: HapticModeData) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<HapticMode> = HapticMode.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let hapticMode = results.first {
                hapticMode.isEnabled = hapticModeData.isEnabled;

                print("Within if let")
            } else {
                let hapticMode = HapticMode(context: context)
                hapticMode.isEnabled = hapticModeData.isEnabled;
                
                print("within else in if let")
            }
            
            try context.save()
        } catch {
            print("Error saving devmode: \(error.localizedDescription)")
        }
    }
    
    func getHapticMode() -> HapticModeData {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<HapticMode> = HapticMode.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let hapticMode = results.first {
                return HapticModeData(isEnabled: hapticMode.isEnabled)
            } else {
                return HapticModeData(isEnabled: true)
            }
        } catch {
            print("Error fetching devmode, defaulting false: \(error.localizedDescription)")
            return HapticModeData(isEnabled: true)
        }
    }
    
    func deleteDevMode() {
        let context = persistentContainer.viewContext
            
        let fetchRequest: NSFetchRequest<HapticMode> = HapticMode.fetchRequest()
        fetchRequest.fetchLimit = 1
            
        do {
            let results = try context.fetch(fetchRequest)
            if let devMode = results.first {
                context.delete(devMode)
                try context.save()
                print("Devmode data deleted successfully")
            } else {
                print("No devmode data found to delete")
            }
        } catch {
            print("Error deleting devmode data: \(error.localizedDescription)")
        }
    }
    
    func swapMode() -> HapticModeData {
        let current:HapticModeData = self.getHapticMode()
        if (current.isEnabled == false) {
            self.saveHapticMode(hapticModeData: HapticModeData(isEnabled: true))
        }
        else {
            self.saveHapticMode(hapticModeData: HapticModeData(isEnabled: false))
        }
        return self.getHapticMode()
    }
}

