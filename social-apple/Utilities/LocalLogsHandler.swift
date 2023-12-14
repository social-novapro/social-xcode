//
//  LocalLogsHandler.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-04.
//

import Foundation
import CoreData

class LocalLogsHandler {
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "social_apple")
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
    }
    
//    func getLocalLogs() -> [LocalLogData] {
//        let context = persistentContainer.viewContext
//        let fetchRequest: NSFetchRequest<LocalLogs> = LocalLogs.fetchRequest()
//        let foundArr: [LocalLogData]
//        do {
//            let results = try context.fetch(fetchRequest)
//            for foundLog in results {
//                foundArr.append(try LocalLogData(from: foundLog as! Decoder))
//            }
//        } catch {
//            print("Error deleting devmode data: \(error.localizedDescription)")
//        }
//        
//        return foundArr
//    }
    
//    func saveLocalLog(localLog: LocalLogData) {
//        let context = persistentContainer.viewContext
//        
//        let fetchRequest: NSFetchRequest<LocalLogs> = LocalLogs.fetchRequest()
//        fetchRequest.fetchLimit = 1
//        
//        do {
//            var results = try context.fetch(fetchRequest)
//            
//            results.append(newElement: localLog)
//
//            try context.save()
//        } catch {
//            print("Error saving devmode: \(error.localizedDescription)")
//        }
//    }
    
//    func deleteLocalLogs() {
//        let context = persistentContainer.viewContext
//            
//        let fetchRequest: NSFetchRequest<LocalLogs> = LocalLogs.fetchRequest()
//        do {
//            let results = try context.fetch(fetchRequest)
//            for foundLog in results {
//                context.delete(foundLog)
//                try context.save()
//            }
//        } catch {
//            print("Error deleting devmode data: \(error.localizedDescription)")
//        }
//
//    }
}

