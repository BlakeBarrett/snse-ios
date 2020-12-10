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
    let jsonWithColor = "{\"color\":\"#ff0000ff\",\"timestamp\":1445473200,\"elaborate\":\"\",\"water\":true,\"feeling\":\"😊\",\"intensity\":50}"
    let enUS = Locale(identifier: "en_US")
    let october_21st_2015_epoch = Double(1445473200)
    
    let prettyPrintedRealWorldJSON = "{\r" +
        "\t\"color\" : \"#ff67a4ff\",\r" +
        "\t\"timestamp\" : 1546131431.5893731,\r" +
        "\t\"elaborate\" : \"Finished vacuuming. Now I'm playing video games.\",\r" +
        "\t\"intensity\" : 75,\r" +
        "\t\"feeling\" : \"😊\",\r" +
        "\t\"water\" : false\r" +
      "}"
    
    func testParsingActualDate() {
        let dateString = "1546131431.5893731"
        guard let dateDouble = Double(dateString) else {
            XCTFail("Parsing went badly.")
            return
        }
        let date = Date(timeIntervalSince1970: dateDouble)
        XCTAssertNotNil(date)
    }
    
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
        let value = Sentiment(jsonString: jsonWithColor)
        
        XCTAssertEqual("😊", value?.feeling)
        XCTAssertEqual(50, value?.intensity)
        XCTAssertEqual("", value?.elaborate)
        XCTAssertEqual(true, value?.water)
        XCTAssertEqual(UIColor.red, value?.color)
    }
    
    func testSerializationWithoutColor() {
        var values = [String: Any]()
        
        values["timestamp"] = 1445473200.0
        values["feeling"] = "😊"
        values["elaborate"] = ""
        values["water"] = true
        values["intensity"] = 50
        
        let expected = Sentiment(values: values)
        let actual = Sentiment(jsonString: json)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testSerializationWithColor() {
        var values = [String: Any]()
        
        values["timestamp"] = 1445473200.0
        values["feeling"] = "😊"
        values["elaborate"] = ""
        values["water"] = true
        values["intensity"] = 50
        values["color"] = UIColor.red
        
        let expected = Sentiment(values: values)
        let actual = Sentiment(jsonString: jsonWithColor)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testDeserializingActualRealWorldJSON() {
        guard let sentiment = Sentiment(jsonString: prettyPrintedRealWorldJSON) else {
            XCTFail("Could not create Sentiment from JSON string provided.")
            return
        }
        
        if let dateDouble = Double("1546131431.5893731") {
            let expected = Date(timeIntervalSince1970: dateDouble)
            let actual = sentiment.timestamp
            XCTAssertEqual(expected, actual)
        } else {
            XCTFail("Parsing Double from String went very badly.")
        }
        
        XCTAssertEqual("12/29, 04:57", sentiment.getDateString())
        XCTAssertEqual("December 29, 2018 at 4:57 PM", sentiment.getLongDateString())
        XCTAssertEqual("😊", sentiment.feeling)
        XCTAssertEqual(false, sentiment.water)
        XCTAssertEqual("Finished vacuuming. Now I'm playing video games.", sentiment.elaborate)
        XCTAssertEqual(75, sentiment.intensity)
        XCTAssertNotNil(sentiment.color)
    }
}
