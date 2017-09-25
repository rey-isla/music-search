//
//  MusicSearchService.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import Foundation

extension Constants {
    struct MusicSearchService {
        static let scheme = "https"
        static let host = "itunes.apple.com"
        static let path = "/search"
        static let defaultResultCount = "50"
        
        /// Maximum results Apple's iTunes API will return.
        ///
        /// Reference: https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
        static let maxResultCount = "200"

        /// Restricts the type of results we'll receive from Apple's iTunes API.
        static let mediaType = "music"
    }
}

class MusicSearchService {
    
    // MARK: - Constants/Type Aliases
    typealias constants = Constants.MusicSearchService
    typealias MusicSearchResponse = (Response<[Song]>)
    
    /// Finds the songs that matches the passed search word limited to the passed result count.
    ///
    /// - Parameters:
    ///     - searchWord: The `String` search term used for the song search
    ///     - resultCount: The `String` count used to limit the results
    ///     - completion: The completion block called after the API returns a response. It captures a
    ///                   `Response<[Song]>` created from the API response.
    func findSongs(matching searchWord: String, limitedTo resultCount: String = constants.defaultResultCount,
                   completion: @escaping (MusicSearchResponse) -> ()) {
        
        let queryItems = [
            URLQueryItem(name: "term", value: searchWord),
            URLQueryItem(name: "media", value: constants.mediaType),
            URLQueryItem(name: "limit", value: resultCount)
        ]
        
        guard let request =
            URLRequest(requestType: .GET, scheme: constants.scheme, host: constants.host, path: constants.path,
                       queryItems: queryItems) else {
                        completion(.Error(.Requesting))
                        return
        }
        
        var songs: [Song] = []
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for
                completion(.Error(.API(errorMessage: error?.localizedDescription ?? "")))
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                completion(.Error(.API(errorMessage: Constants.Response.invalidStatusCode)))
                return
            }
            
            guard let rawJson = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = rawJson as? [String: Any], let jsonSongs = json["results"] as? [[String: Any]] else {
                    completion(.Error(.Parsing))
                    return
            }

            for jsonSong in jsonSongs {
                if let song = Song(json: jsonSong) {
                    songs.append(song)
                }
            }

            completion(.Success(songs))
        }.resume()
    }
    
    /// Finds all songs that matches the passed search word.
    ///
    /// - Parameters:
    ///     - searchWord: The `String` search term used for the song search
    ///     - completion: The completion block called after the API returns a response. It captures a `Response<[Song]>`
    ///                   created from the API response.
    func findAllSongs(matching searchWord: String, completion: @escaping (MusicSearchResponse) -> ()) {
        findSongs(matching: searchWord, limitedTo: constants.maxResultCount, completion: completion)
    }
}
