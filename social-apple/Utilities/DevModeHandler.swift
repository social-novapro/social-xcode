//
//  DeveloperModeHandler.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-28.
//

import Foundation
import CoreData

class DevModeHandler {
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "social_apple")
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
    }
    
    func saveDevMode(devTokenData: DevModeData) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<DevMode> = DevMode.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let devMode = results.first {
                devMode.isEnabled = devTokenData.isEnabled;

                print("Within if let")
            } else {
                let devMode = DevMode(context: context)
                devMode.isEnabled = devTokenData.isEnabled;
                
                print("within else in if let")
            }
            
            try context.save()
        } catch {
            print("Error saving devmode: \(error.localizedDescription)")
        }
    }
    
    func getDevMode() -> DevModeData {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<DevMode> = DevMode.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let devMode = results.first {
                return DevModeData(isEnabled: devMode.isEnabled)
            } else {
                return DevModeData(isEnabled: false)
            }
        } catch {
            print("Error fetching devmode, defaulting false: \(error.localizedDescription)")
            return DevModeData(isEnabled: false)
        }
    }
    
    func deleteDevMode() {
        let context = persistentContainer.viewContext
            
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.fetchLimit = 1
            
        do {
            let results = try context.fetch(fetchRequest)
            if let userTokens = results.first {
                context.delete(userTokens)
                try context.save()
                print("Devmode data deleted successfully")
            } else {
                print("No devmode data found to delete")
            }
        } catch {
            print("Error deleting devmode data: \(error.localizedDescription)")
        }
    }
    func swapMode() -> DevModeData {
        let current:DevModeData = self.getDevMode()
        if (current.isEnabled == false) {
            self.saveDevMode(devTokenData: DevModeData(isEnabled: true))
        }
        else {
            self.saveDevMode(devTokenData: DevModeData(isEnabled: false))
        }
        return self.getDevMode()
    }
}

