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
    
    static func load() -> [Sentiment] {
        var results = [Sentiment]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SentimentEntity")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let sentiment = Sentiment(managedObject: data) {
                    results.append(sentiment)
                }
            }
        } catch {
            print("Failed")
        }
        return results
    }
    
    static func save(_ value: Sentiment) {
        let _ = value.managedObject(in: context)
        do {
            try context.save()
        } catch {
            return
        }
    }
}
