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

class Sentiment: Encodable, Hashable, Equatable {
    
    static func == (lhs: Sentiment, rhs: Sentiment) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
    
    static func < (lhs: Sentiment, rhs: Sentiment) -> Bool {
        let lhsTs = Double(lhs.timestamp?.timeIntervalSince1970 ?? 0)
        let rhsTs = Double(rhs.timestamp?.timeIntervalSince1970 ?? 0)
        return lhsTs < rhsTs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
    }
    
    enum Feels: String {
        case sad = "😞",
        meh = "😐",
        happy = "😊"
        
        static var all: [String] {
            return [Feels.sad.rawValue, Feels.meh.rawValue, Feels.happy.rawValue]
        }
    }
    
    enum Fields: String, CodingKey {
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
                } else if let date = value as? Int {
                    self.timestamp = Date(timeIntervalSince1970: Double(date))
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
                } else if let color = value as? UIColor {
                    self.color = color
                }
                break
            default: break
            }
        }
        
        if self.timestamp == nil {
            self.timestamp = Date()
        }
    }
    
    convenience init?(jsonString: String) {
        var values = [String: Any]()
        do {
            if let data = jsonString.data(using: .utf16) {
                values = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            }
        } catch {
            
        }
        self.init(values: values)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Fields.self)
        
        let timeValue = timestamp?.timeIntervalSince1970
        
        try container.encode(timeValue, forKey: .timestamp)
        try container.encode(feeling, forKey: .feeling)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(water, forKey: .water)
        if let rgbaColor = color?.toRGBAString() {
            try container.encode(rgbaColor, forKey: .color)
        }
        try container.encode(elaborate, forKey: .elaborate)
    }
    
    func jsonString() -> String {
        let encoder = JSONEncoder()
        
        do {
            let encoded = try encoder.encode(self)
            let str = String(decoding: encoded, as: UTF8.self)
            return str
        } catch {
            return error.localizedDescription
        }
    }
}

// db helper function
extension Sentiment {
    func managedObject(in context: NSManagedObjectContext) -> NSManagedObject? {
        if let entity = NSEntityDescription.entity(forEntityName: "SentimentEntity", in: context) {
            let sentiment = NSManagedObject(entity: entity, insertInto: context)
            sentiment.setValue(self.timestamp, forKey: Fields.timestamp.rawValue)
            sentiment.setValue(self.feeling, forKey: Fields.feeling.rawValue)
            sentiment.setValue(self.intensity, forKey: Fields.intensity.rawValue)
            sentiment.setValue(self.water, forKey: Fields.water.rawValue)
            sentiment.setValue(self.color?.toRGBAString(), forKey: Fields.color.rawValue)
            sentiment.setValue(self.elaborate, forKey: Fields.elaborate.rawValue)
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
    
    static let yesterday = "Yesterday "
    static let ayer = "Ayer "
    
    func spanishLangCode() -> String? {
        return Locale.init(identifier: "es").languageCode
    }
    
    func isSpanishLocale() -> Bool {
        return Locale.autoupdatingCurrent.languageCode == spanishLangCode()
    }
    
    func getDateString(forLocale locale: Locale = Locale.autoupdatingCurrent) -> String {
        let calendar = NSCalendar.autoupdatingCurrent
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        if calendar.isDateInToday(timestamp!) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else if calendar.isDateInYesterday(timestamp!) {
            
            if isSpanishLocale() {
                return Sentiment.ayer
            }
            
            return Sentiment.yesterday
        } else {
            dateFormatter.dateFormat = "MM/dd, hh:mm"
        }
        return dateFormatter.string(from: timestamp!)
    }
    
    func getLongDateString(forLocale locale: Locale = Locale.autoupdatingCurrent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        guard let timestamp = timestamp else { return "" }
        
        var dayString = ""
        let calendar = NSCalendar.autoupdatingCurrent
        if calendar.isDateInToday(timestamp) {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        } else if calendar.isDateInYesterday(timestamp) {
            switch Locale.autoupdatingCurrent.languageCode {
            case spanishLangCode():
                dayString = Sentiment.ayer
                break
            default:
                dayString = Sentiment.yesterday
                break
            }
            dateFormatter.dateStyle = .none
        }
        
        return dayString + dateFormatter.string(from: timestamp)
    }
}
