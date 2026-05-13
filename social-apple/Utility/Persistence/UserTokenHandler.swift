//
//  GetUserTokens.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import Foundation
import CoreData

class UserTokenHandler {
    private let persistentContainer: NSPersistentContainer
    private let legacyActiveUserIDKey = "social.activeUserID"
    
    init(persistentContainer: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = persistentContainer
    }
    
    func saveUserTokens(userTokenData: UserTokenData) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userTokenData.userID)
        
        do {
            let results = try context.fetch(fetchRequest)
            let userTokens = results.first ?? UserTokens(context: context)
            
            userTokens.accessToken = userTokenData.accessToken
            userTokens.userToken = userTokenData.userToken
            userTokens.userID = userTokenData.userID
            
            for duplicate in results.dropFirst() {
                context.delete(duplicate)
            }
            
            setOnlyActiveUserToken(userTokens, context: context)
            try context.save()
        } catch {
            print("Error saving user tokens: \(error.localizedDescription)")
        }
    }
    
    func getUserTokens() -> UserTokenData? {
        let context = persistentContainer.viewContext
        
        if let activeUserTokens = getActiveUserToken(context: context),
           let activeUserTokenData = userTokenData(from: activeUserTokens) {
            return activeUserTokenData
        }
        
        if let migratedActiveUserTokenData = migrateLegacyActiveUserID(context: context) {
            return migratedActiveUserTokenData
        }
        
        return getLegacyUserTokens(context: context)
    }
    
    func getAllUserTokens() -> [UserTokenData] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap(userTokenData(from:))
        } catch {
            print("Error fetching all user tokens: \(error.localizedDescription)")
            return []
        }
    }
    
    func switchActiveUser(userID: String) -> UserTokenData? {
        let context = persistentContainer.viewContext
        
        guard let userTokens = getUserToken(userID: userID, context: context),
              let userTokenData = userTokenData(from: userTokens) else {
            return nil
        }
        
        do {
            setOnlyActiveUserToken(userTokens, context: context)
            try context.save()
            return userTokenData
        } catch {
            print("Error switching active user token: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteUserToken() {
        _ = deleteCurrentUserToken()
    }
    
    @discardableResult
    func deleteCurrentUserToken() -> UserTokenData? {
        let context = persistentContainer.viewContext
        
        guard let currentUserTokens = getActiveUserToken(context: context) ?? getLegacyUserToken(context: context) else {
            return nil
        }
        
        context.delete(currentUserTokens)
        
        do {
            let nextUserTokens = try firstAvailableUserToken(context: context)
            if let nextUserTokens {
                setOnlyActiveUserToken(nextUserTokens, context: context)
            }
            
            try context.save()
            return nextUserTokens.flatMap(userTokenData(from:))
        } catch {
            print("Error deleting current user token data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteUserToken(userID: String) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        
        do {
            let results = try context.fetch(fetchRequest)
            let removedActiveToken = results.contains { $0.active }
            
            if results.isEmpty {
                print("No user token data found to delete")
            } else {
                for userTokens in results {
                    context.delete(userTokens)
                }
            }
            
            if removedActiveToken, let nextUserTokens = try firstAvailableUserToken(context: context) {
                setOnlyActiveUserToken(nextUserTokens, context: context)
            }
            
            try context.save()
            print("User token data deleted successfully")
        } catch {
            print("Error deleting user token data: \(error.localizedDescription)")
        }
    }
    
    func deleteAllUserTokens() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            for userTokens in results {
                context.delete(userTokens)
            }
            try context.save()
            print("All user token data deleted successfully")
        } catch {
            print("Error deleting all user token data: \(error.localizedDescription)")
        }
    }
    
    private func getLegacyUserTokens(context: NSManagedObjectContext) -> UserTokenData? {
        guard let userTokens = getLegacyUserToken(context: context),
              let userTokenData = userTokenData(from: userTokens) else {
            return nil
        }
        
        do {
            setOnlyActiveUserToken(userTokens, context: context)
            try context.save()
            return userTokenData
        } catch {
            print("Error activating legacy user tokens: \(error.localizedDescription)")
            return userTokenData
        }
    }
    
    private func getLegacyUserToken(context: NSManagedObjectContext) -> UserTokens? {
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching legacy user tokens: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func migrateLegacyActiveUserID(context: NSManagedObjectContext) -> UserTokenData? {
        guard let legacyActiveUserID = UserDefaults.standard.string(forKey: legacyActiveUserIDKey),
              !legacyActiveUserID.isEmpty,
              let userTokens = getUserToken(userID: legacyActiveUserID, context: context),
              let userTokenData = userTokenData(from: userTokens) else {
            return nil
        }
        
        do {
            setOnlyActiveUserToken(userTokens, context: context)
            try context.save()
            return userTokenData
        } catch {
            print("Error migrating legacy active user token: \(error.localizedDescription)")
            return userTokenData
        }
    }
    
    private func getActiveUserToken(context: NSManagedObjectContext) -> UserTokens? {
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "active == YES")
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching active user tokens: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getUserToken(userID: String, context: NSManagedObjectContext) -> UserTokens? {
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching user tokens for \(userID): \(error.localizedDescription)")
            return nil
        }
    }
    
    private func firstAvailableUserToken(context: NSManagedObjectContext) throws -> UserTokens? {
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        return try context.fetch(fetchRequest).first { !$0.isDeleted }
    }
    
    private func setOnlyActiveUserToken(_ activeUserToken: UserTokens, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "active == YES")
        
        do {
            let results = try context.fetch(fetchRequest)
            for userTokens in results {
                guard !userTokens.isDeleted else {
                    continue
                }
                userTokens.active = false
            }
            activeUserToken.active = true
            UserDefaults.standard.removeObject(forKey: legacyActiveUserIDKey)
        } catch {
            print("Error updating active user token flag: \(error.localizedDescription)")
        }
    }
    
    private func userTokenData(from userTokens: UserTokens) -> UserTokenData? {
        guard let accessToken = userTokens.accessToken,
              let userToken = userTokens.userToken,
              let userID = userTokens.userID,
              !accessToken.isEmpty,
              !userToken.isEmpty,
              !userID.isEmpty else {
            return nil
        }
        
        return UserTokenData(accessToken: accessToken, userToken: userToken, userID: userID)
    }
}
