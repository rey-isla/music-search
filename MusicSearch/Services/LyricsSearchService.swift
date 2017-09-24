//
//  LyricsSearchService.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import Foundation

extension Constants {
    struct LyricsSearchService {
        static let scheme = "http"
        static let host = "lyrics.wikia.com"
        static let path = "/api.php"
        static let function = "getSong"
        
        /// The correct format for getting proper json from the API is "realjson" but the requirements suggest using
        /// "json" so we'll handle the formatting issues using a custom JSONSerialization extension static method called
        /// cleanedJsonObject(from data: Data)
        static let format = "json"

        /// Restricts the type of results we'll receive from Apple's iTunes API.
        static let mediaType = "music"
    }
}

class LyricsSearchService {
    
    typealias constants = Constants.LyricsSearchService
    typealias LyricsSearchResponse = (Response<String>)
    
    func findLyrics(of songName: String, by artistName: String, completion: @escaping (LyricsSearchResponse) -> ()) {
        
        let queryItems = [
            URLQueryItem(name: "song", value: songName),
            URLQueryItem(name: "artist", value: artistName),
            URLQueryItem(name: "func", value: constants.function),
            URLQueryItem(name: "fmt", value: constants.format)
        ]
        
        guard let request =
            URLRequest(requestType: .GET, scheme: constants.scheme, host: constants.host, path: constants.path,
                       queryItems: queryItems) else {
                        completion(.Error(.Requesting))
                        return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.Error(.API(errorMessage: error?.localizedDescription ?? "")))
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                completion(.Error(.API(errorMessage: "Invalid Status Code")))
                return
            }
            
            // Use a custom JSONSerialization extension method of cleaning up the data because the format returned
            // by the API is invalid JSON.
            guard let rawJson = JSONSerialization.cleanedJsonObject(from: data), let json = rawJson as? [String: Any],
                let lyrics = json["lyrics"] as? String else {
                    completion(.Error(.Parsing))
                    return
            }
            
            let isDataValid = (try? JSONSerialization.jsonObject(with: data, options: [])) != nil
            
            if isDataValid {
                completion(.Success(lyrics))
            } else {
                // If the data was an invalidly formatted JSON, we need to change all doubles quotes back into single
                // quotes to revert the changes done by the data clean up process.
                completion(.Success(lyrics.replacingOccurrences(of: "\"", with: "'")))
            }
        }.resume()
    }
}
