//
//  Sentiment.swift
//  snse
//
//  Created by Blake Barrett on 11/10/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Sentiment {
    
    enum Fields: String {
        case timestamp = "timestamp",
        water = "water",
        elaborate = "elaborate",
        feeling = "feeling",
        intensity = "intensity",
        color = "color"
        
        static func keys() -> [String] {
            return [
                Fields.timestamp.rawValue,
                Fields.water.rawValue,
                Fields.elaborate.rawValue,
                Fields.feeling.rawValue,
                Fields.intensity.rawValue,
                Fields.color.rawValue
            ]
        }
    }
    
    var timestamp: Date?
    var elaborate, feeling: String?
    var intensity: Int?
    var color: UIColor?
    var water: Bool = false
    
    init() {
        self.timestamp = Date()
    }
    
    convenience init?(managedObject values: NSManagedObject) {
        let valuesDict = values.dictionaryWithValues(forKeys: Fields.keys())
        self.init(values: valuesDict)
    }
    
    init?(values: [String: Any]) {
        for (key, value) in values {
            switch key {
            case Fields.timestamp.rawValue:
                // Are we loading from the db?
                if let date = value as? Date {
                    self.timestamp = date
                }
                break
            case Fields.water.rawValue:
                self.water = (value as? Bool) ?? false
                break
            case Fields.elaborate.rawValue:
                self.elaborate = value as? String
                break
            case Fields.feeling.rawValue:
                self.feeling = value as? String
                break
            case Fields.intensity.rawValue:
                self.intensity = value as? Int
                break
            case Fields.color.rawValue:
                if let colorString = value as? String {
                    self.color = UIColor(hexaDecimalString: colorString)
                }
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
            sentiment.setValue(self.intensity, forKey: Fields.intensity.rawValue)
            sentiment.setValue(self.color?.toRGBAString(), forKey: Fields.color.rawValue)
            return sentiment
        }
        return nil
    }
}

extension Sentiment: CustomStringConvertible {
    var description: String {
        return "\(getDateString()) \(self.feeling ?? "") \(self.elaborate ?? "")"
    }
}

extension Sentiment {
    
    func getDateString() -> String {
        let calendar = NSCalendar.autoupdatingCurrent
        let dateFormatter = DateFormatter()
        if calendar.isDateInToday(timestamp!) {
            dateFormatter.dateFormat = "hh:mm"
        } else if calendar.isDateInYesterday(timestamp!) {
            
            if Locale.current.languageCode == Locale.init(identifier: "es").languageCode {
                return "Ayer"
            }
            
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MM/dd, hh:mm"
        }
        return dateFormatter.string(from: timestamp!)
    }
    
}
