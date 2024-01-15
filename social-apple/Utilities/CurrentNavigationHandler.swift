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
                currentNavigation.expanded = currentNavigationData.expanded ?? false;


                print("Within if let")
            } else {
                let currentNavigation = CurrentNavigation(context: context)
                currentNavigation.selectedTab = currentNavigationData.selectedTab;
                currentNavigation.expanded = currentNavigationData.expanded ?? false;

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
        
        print("getting nav")
        do {
            let results = try context.fetch(fetchRequest)
            if let currentNavigation = results.first {
                if (currentNavigation.expanded) {
                    return CurrentNavigationData(selectedTab: currentNavigation.selectedTab, expanded: currentNavigation.expanded)

                } else {
                    return CurrentNavigationData(selectedTab: currentNavigation.selectedTab, expanded: false)
                }
            } else {
                return CurrentNavigationData(selectedTab: 0, expanded: false)
            }
        } catch {
            print("Error fetching current navigation, defaulting 0: \(error.localizedDescription)")
            return CurrentNavigationData(selectedTab: 0, expanded: false)
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
        let current:CurrentNavigationData = self.getCurrentNavigation()
        if (newTab>5) {
            print("higher than expected switchTab()")
            return self.getCurrentNavigation()
        }
        print("switching to page \(newTab)")
        self.saveCurrentNavigation(currentNavigationData: CurrentNavigationData(selectedTab: newTab, expanded: current.expanded))
        
        return self.getCurrentNavigation()
    }
    func swapExpanded() -> CurrentNavigationData {
        let current:CurrentNavigationData = self.getCurrentNavigation()

        var newExpand:Bool = current.expanded ?? false;
        newExpand.toggle()
        
        print("swapping expanded")
        self.saveCurrentNavigation(currentNavigationData: CurrentNavigationData(selectedTab: current.selectedTab, expanded: newExpand))
        
        return self.getCurrentNavigation()
    }
}


