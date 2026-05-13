//
//  AppPreferenceHandler.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import Foundation
import CoreData

class AppPreferenceHandler {
    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = persistentContainer
    }
    
    func saveAppPreferences(appPreferencesData: AppPreferencesData) {
        let context = persistentContainer.viewContext
        let userID = normalizedUserID(appPreferencesData.userID)
        let fetchRequest: NSFetchRequest<AppPreferences> = AppPreferences.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        
        do {
            let results = try context.fetch(fetchRequest)
            let appPreferences = results.first ?? AppPreferences(context: context)
            
            appPreferences.userID = userID
            appPreferences.appearancePreference = appPreferencesData.appearancePreference.rawValue
            appPreferences.designPreference = appPreferencesData.designPreference.rawValue
            
            try context.save()
        } catch {
            print("Error saving app preferences: \(error.localizedDescription)")
        }
    }
    
    func getAppPreferences(userID: String?) -> AppPreferencesData {
        let context = persistentContainer.viewContext
        let normalizedID = normalizedUserID(userID)
        let fetchRequest: NSFetchRequest<AppPreferences> = AppPreferences.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "userID == %@", normalizedID)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let appPreferences = results.first {
                return AppPreferencesData(
                    userID: normalizedID,
                    appearancePreference: InteractAppearancePreference(rawValue: appPreferences.appearancePreference ?? "") ?? .system,
                    designPreference: InteractDesignPreference(rawValue: appPreferences.designPreference ?? "") ?? .original
                )
            }
        } catch {
            print("Error fetching app preferences, defaulting original/system: \(error.localizedDescription)")
        }
        
        return AppPreferencesData(
            userID: normalizedID,
            appearancePreference: .system,
            designPreference: .original
        )
    }
    
    func setAppearancePreference(_ preference: InteractAppearancePreference, userID: String?) -> AppPreferencesData {
        var current = getAppPreferences(userID: userID)
        current.appearancePreference = preference
        saveAppPreferences(appPreferencesData: current)
        return getAppPreferences(userID: userID)
    }
    
    func setDesignPreference(_ preference: InteractDesignPreference, userID: String?) -> AppPreferencesData {
        var current = getAppPreferences(userID: userID)
        current.designPreference = preference
        saveAppPreferences(appPreferencesData: current)
        return getAppPreferences(userID: userID)
    }
    
    private func normalizedUserID(_ userID: String?) -> String {
        guard let userID = userID?.trimmingCharacters(in: .whitespacesAndNewlines),
              userID.isEmpty == false else {
            return "default"
        }
        
        return userID
    }
}
