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
    ///
    /// - Parameters:
    ///     - data: The `Data` to be cleaned
    /// - Returns: `Any?` object representing the raw JSON object from the cleaned data
    static func cleanedJsonObject(from data: Data) -> Any? {
        let rawJson = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let _ = rawJson { return rawJson }
        
        guard var stringDataRepresentation = String(data: data, encoding: .utf8) else {
            return rawJson
        }

        // Attempt to clean up invalid data by removing any characters before the first opening curly bracket.
        guard let indexOfFirstCurlyBracket = stringDataRepresentation.index(of: "{") else {
            // If there are no curly brackets in the data, simply return the original object because we can't
            // perform cleanup on the data.
            return rawJson
        }
        
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
