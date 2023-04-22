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
    
    init() {
        persistentContainer = NSPersistentContainer(name: "social_apple")
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
    }
    
    func saveUserTokens(userTokenData: UserTokenData) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let userTokens = results.first {
                userTokens.accessToken = userTokenData.accessToken
                userTokens.userToken = userTokenData.userToken
                userTokens.userID = userTokenData.userID
                print("Within if let")
            } else {
                let userTokens = UserTokens(context: context)
                userTokens.accessToken = userTokenData.accessToken
                userTokens.userToken = userTokenData.userToken
                userTokens.userID = userTokenData.userID
                print("within else in if let")
            }
            
            try context.save()
        } catch {
            print("Error saving user tokens: \(error.localizedDescription)")
        }
    }
    
    func getUserTokens() -> UserTokenData? {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let userTokens = results.first {
                return UserTokenData(accessToken: userTokens.accessToken!, userToken: userTokens.userToken!, userID: userTokens.userID!)
            } else {
                return nil
            }
        } catch {
            print("Error fetching user tokens: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteUserToken() {
        let context = persistentContainer.viewContext
            
        let fetchRequest: NSFetchRequest<UserTokens> = UserTokens.fetchRequest()
        fetchRequest.fetchLimit = 1
            
        do {
            let results = try context.fetch(fetchRequest)
            if let userTokens = results.first {
                context.delete(userTokens)
                try context.save()
                print("User token data deleted successfully")
            } else {
                print("No user token data found to delete")
            }
        } catch {
            print("Error deleting user token data: \(error.localizedDescription)")
        }
    }

}

