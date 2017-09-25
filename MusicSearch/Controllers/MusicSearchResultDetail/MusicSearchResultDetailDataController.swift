//
//  MusicSearchResultDetailDataController.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import UIKit

extension Constants {
    struct MusicSearchResultDetailDataController {
        static let lyricsNotFoundError = NSLocalizedString("Lyrics Not Found", comment: "")
    }
}

class MusicSearchResultDetailDataController {
    
    // MARK: - Constants
    typealias constants = Constants.MusicSearchResultDetailDataController
    
    // Delay instantiation of services until needed using lazy variables. Ideally, we should inject this by
    // dependency injection but in interest of expediency, we'll allow the data controller to instantiate its own
    // services.
    private lazy var lyricsSearchService = LyricsSearchService()
    private lazy var imageDownloadService = ImageDownloadService()
}

extension MusicSearchResultDetailDataController: LyricsSearchDataController {
    
    /// Finds the lyrics of the passed song and artist.
    ///
    /// - Parameters:
    ///     - songName: The `String` search term used for the song name search
    ///     - artistName: The `String` search term used for the song's artist name search
    ///     - completion: The completion block called after the service returns a response. It captures a `String`
    ///                   created from the service response.
    func findLyrics(of songName: String, by artistName: String, completion: @escaping (String) -> ()) {
        lyricsSearchService.findLyrics(of: songName, by: artistName) { response in
            switch response {
                case .Error:
                    completion(constants.lyricsNotFoundError)
                    return
                case .Success(let lyrics):
                    completion(lyrics)
                    return
            }
        }
    }
}

extension MusicSearchResultDetailDataController: ImageSearchDataController {
    
    /// Downloads the image from the passed image URL.
    ///
    /// - Parameters:
    ///     - imageUrl: The `URL` of the requested image
    ///     - completion: The completion block called after the service returns a response. It captures a `UIImage`
    ///                   created from the service response.
    func downloadImage(from imageUrl: URL, completion: @escaping (UIImage) -> ()) {
        imageDownloadService.downloadImage(from: imageUrl) { response in
            switch response {
                case .Error:
                    completion(UIImage(named: "albumImagePlaceholder") ?? UIImage())
                    return
                case .Success(let image):
                    completion(image)
                    return
            }
        }
    }
}
