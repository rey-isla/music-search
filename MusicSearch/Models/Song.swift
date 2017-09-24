//
//  Song.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import Foundation

struct Song {
    let name: String
    let artistName: String
    let albumName: String
    let albumImageLargeUrl: URL
    let albumImageSmallUrl: URL
    
    init?(json: [String: Any]) {
        guard let name = json["trackName"] as? String,
            let albumName = json["collectionName"] as? String,
            let artistName = json["artistName"] as? String,
            let albumImageLargeUrlString = json["artworkUrl100"] as? String,
            let albumImageLargeUrl = URL(string: albumImageLargeUrlString),
            let albumImageSmallUrlString = json["artworkUrl60"] as? String,
            let albumImageSmallUrl = URL(string: albumImageSmallUrlString)
            else {
                return nil
        }
        
        self.name = name
        self.albumName = albumName
        self.artistName = artistName
        self.albumImageLargeUrl = albumImageLargeUrl
        self.albumImageSmallUrl = albumImageSmallUrl
    }
}
