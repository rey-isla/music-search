//
//  JSONSerialization.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import Foundation

extension JSONSerialization {
   
    /// Attempts to return a JSON object by cleaning invalid formatted data. 
    static func cleanedJsonObject(from data: Data) -> Any? {
        let rawJson = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let _ = rawJson { return rawJson }
        
        // Attempt to handle invalid JSON format by removing any characters before the first curly bracket
        guard var stringDataRepresentation = String(data: data, encoding: .utf8) else {
            return rawJson
        }
        
        guard let indexOfFirstCurlyBracket = stringDataRepresentation.index(of: "{") else {
            return rawJson
        }
        
        // Clean up the invalid data by removing any characters before the first opening curly bracket.
        let invalidJsonStringRangeToRemove = stringDataRepresentation.startIndex..<indexOfFirstCurlyBracket
        stringDataRepresentation.removeSubrange(invalidJsonStringRangeToRemove)
        
        // Perform additonal clean up by replacing unescaped double quotes with escaped double quotes
        stringDataRepresentation = stringDataRepresentation.replacingOccurrences(of: "\u{22}", with: "\\\u{22}")
        
        // Perform additonal clean up by replacing single quotes with double quotes
        stringDataRepresentation = stringDataRepresentation.replacingOccurrences(of: "'", with: "\"")
        
        guard let cleanedData = stringDataRepresentation.data(using: .utf8) else {
            return rawJson
        }
        
        return try? JSONSerialization.jsonObject(with: cleanedData, options: [])
    }
    
}
