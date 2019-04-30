//
//  SentimentTests.swift
//  snseTests
//
//  Created by Blake Barrett on 4/28/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import XCTest

class SentimentTests: XCTestCase {
    
    let json = "{\"timestamp\":1445473200,\"elaborate\":\"\",\"water\":true,\"feeling\":\"😊\",\"intensity\":50}"
    let enUS = Locale(identifier: "en_US")
    let october_21st_2015_epoch = Double(1445473200)
    
    // NOTE: date rendering tests will fail if not in the Pacific timezone.
    func testShortDateString() {
        var values = [String: Any]()
        let october_21st_2015 = Date(timeIntervalSince1970: october_21st_2015_epoch)
        values["timestamp"] = october_21st_2015
        let sentiment = Sentiment(values: values)
        
        let expected = "10/21, 05:20"
        let actual = sentiment?.getDateString(forLocale: enUS)
        XCTAssertEqual(expected, actual)
    }
    
    // NOTE: date rendering tests will fail if not in the Pacific timezone.
    func testLongDateString() {
        var values = [String: Any]()
        let october_21st_2015 = Date(timeIntervalSince1970: october_21st_2015_epoch)
        values["timestamp"] = october_21st_2015
        let sentiment = Sentiment(values: values)
        
        let expected =  "October 21, 2015 at 5:20 PM"
        let actual = sentiment?.getLongDateString(forLocale: enUS)
        XCTAssertEqual(expected, actual)
    }
    
    func testDeSerialization() {
        let value = Sentiment(jsonString: json)
        
        XCTAssertEqual("😊", value?.feeling)
        XCTAssertEqual(50, value?.intensity)
        XCTAssertEqual("", value?.elaborate)
        XCTAssertEqual(true, value?.water)
    }
    
    func testSerialization() {
        var values = [String: Any]()
        
        values["timestamp"] = 1445473200
        values["feeling"] = "😊"
        values["elaborate"] = ""
        values["water"] = true
        values["intensity"] = 50
        let sentiment = Sentiment(values: values)
        
        let actual = sentiment?.jsonString()
        XCTAssertEqual(json, actual)
    }
    
}

