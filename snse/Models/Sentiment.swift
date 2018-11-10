//
//  Sentiment.swift
//  snse
//
//  Created by Blake Barrett on 11/10/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import CoreData

class Sentiment: Codable {
    
    enum Fields: String {
        case timestamp = "timestamp",
        water = "water",
        elaborate = "elaborate",
        feeling = "feeling",
        url = "url"
        
        static func keys() -> [String] {
            return [
                Fields.timestamp.rawValue,
                Fields.water.rawValue,
                Fields.elaborate.rawValue,
                Fields.feeling.rawValue,
                Fields.url.rawValue]
        }
    }
    
    var timestamp: Date?
    var elaborate, feeling, url: String?
    var water: Bool = false
    
    convenience init?(managedObject values: NSManagedObject) {
        let valuesDict = values.dictionaryWithValues(forKeys: Fields.keys())
        self.init(values: valuesDict)
    }
    
    init?(values: [String: Any]) {
        for (key, value) in values {
            switch key {
            case Fields.timestamp.rawValue:
                // First try as an int (from JavaScript)
                if  let epoch = value as? Int,
                    let timeInterval = TimeInterval(exactly: epoch / 1000) {
                    let epochDate = Date(timeIntervalSince1970: timeInterval)
                    self.timestamp = epochDate
                } else if let date = value as? Date {
                        self.timestamp = date
                }
                break
            case Fields.water.rawValue:
                self.water = true
                break
            case Fields.elaborate.rawValue:
                self.elaborate = value as? String
                break
            case Fields.feeling.rawValue:
                self.feeling = value as? String
                break
            case Fields.url.rawValue:
                self.url = value as? String
                break
            default: break
            }
        }
    }
}

// db helper function
extension Sentiment {
    func managedObject(in context: NSManagedObjectContext) -> NSManagedObject? {
        if let entity = NSEntityDescription.entity(forEntityName: "SentimentEntity", in: context) {
            let sentiment = NSManagedObject(entity: entity, insertInto: context)
            sentiment.setValue(self.timestamp, forKey: Fields.timestamp.rawValue)
            sentiment.setValue(self.water, forKey: Fields.water.rawValue)
            sentiment.setValue(self.elaborate, forKey: Fields.elaborate.rawValue)
            sentiment.setValue(self.feeling, forKey: Fields.feeling.rawValue)
            sentiment.setValue(self.url, forKey: Fields.url.rawValue)
            return sentiment
        }
        return nil
    }
}

// Serialization for Codable/JSON
extension Sentiment {
    static func deserialize(from json: String) -> Sentiment? {
        if  let data = json.data(using: .utf8),
            let result = try? JSONDecoder().decode(Sentiment.self, from: data){
            return result
        }
        return nil
    }
    
    func serialize() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // if necessary
        if  let data = try? encoder.encode(self),
            let result = String(data: data, encoding: .utf8){
            return result
        } else {
            return ""
        }
    }
}

extension Sentiment: CustomStringConvertible {
    var description: String {
        return serialize()
    }
}
