//
//  SentimentFactory.swift
//  snse
//
//  Created by Blake Barrett on 11/10/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SentimentFactory {
    
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func load(from context: NSManagedObjectContext, filter: String? = nil) -> [Sentiment] {
        var results = [Sentiment]()
        let result = search(in: context, for: filter)
        for data in result {
            if let sentiment = Sentiment(managedObject: data) {
                results.append(sentiment)
            }
        }
        return results
    }
    
    static func load(from context: NSManagedObjectContext, withPredicate predicate: NSPredicate?) -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SentimentEntity")
        if let _ = predicate {
            request.predicate = predicate
        }
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            return result as! [NSManagedObject]
        } catch {
            print("Failed")
        }
        return [NSManagedObject]()
    }
    
    static func search(in context: NSManagedObjectContext, for query: String?) -> [NSManagedObject] {
        var predicate: NSPredicate? = nil
        if let query = query {
            predicate = NSPredicate(format: "(feeling CONTAINS[cd] %@) OR (elaborate CONTAINS[cd] %@)", query, query)
        }
        return load(from: context, withPredicate: predicate)
    }
    
    static func save(_ value: [Sentiment]) {
        value.forEach{ item in
            save(item)
        }
    }
    
    static func save(_ value: Sentiment) {
        let _ = value.managedObject(in: context)
        do {
            try context.save()
        } catch {
            return
        }
    }
    
    static func delete(_ value: Sentiment) -> Bool {
        let predicate = NSPredicate(format: "timestamp == %@", value.timestamp! as NSDate)
        if let managedObject = load(from: context, withPredicate: predicate).first {
            context.delete(managedObject)
            do {
                try context.save()
            } catch {
                return false
            }
            return true
        }
        return false
    }
}
