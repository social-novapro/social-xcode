//
//  NavigationHandler.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-11.
//

import Foundation
import CoreData

class CurrentNavigationHandler {
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "social_apple")
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
    }
    
    func saveCurrentNavigation(currentNavigationData: CurrentNavigationData) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<CurrentNavigation> = CurrentNavigation.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let currentNavigation = results.first {
                currentNavigation.selectedTab = currentNavigationData.selectedTab;

                print("Within if let")
            } else {
                let currentNavigation = CurrentNavigation(context: context)
                currentNavigation.selectedTab = currentNavigationData.selectedTab;
                
                print("within else in if let")
            }
            
            try context.save()
        } catch {
            print("Error saving devmode: \(error.localizedDescription)")
        }
    }
    
    func getCurrentNavigation() -> CurrentNavigationData {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<CurrentNavigation> = CurrentNavigation.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let currentNavigation = results.first {
                return CurrentNavigationData(selectedTab: currentNavigation.selectedTab)
            } else {
                return CurrentNavigationData(selectedTab: 0)
            }
        } catch {
            print("Error fetching current navigation, defaulting 0: \(error.localizedDescription)")
            return CurrentNavigationData(selectedTab: 0)
        }
    }
    func deleteCurrentNavigation() {
        let context = persistentContainer.viewContext
            
        let fetchRequest: NSFetchRequest<CurrentNavigation> = CurrentNavigation.fetchRequest()
        fetchRequest.fetchLimit = 1
            
        do {
            let results = try context.fetch(fetchRequest)
            if let currentNavigation = results.first {
                context.delete(currentNavigation)
                try context.save()
                print("Devmode data deleted successfully")
            } else {
                print("No devmode data found to delete")
            }
        } catch {
            print("Error deleting devmode data: \(error.localizedDescription)")
        }
    }
    
    func switchTab(newTab: Int16) -> CurrentNavigationData {
//        let current:CurrentNavigationData = self.getCurrentNavigation()
        if (newTab>5) {
            print("higher than expected switchTab()")
            return self.getCurrentNavigation()
        }
        print("switching to page \(newTab)")
        self.saveCurrentNavigation(currentNavigationData: CurrentNavigationData(selectedTab: newTab))
        
        return self.getCurrentNavigation()
    }
}


