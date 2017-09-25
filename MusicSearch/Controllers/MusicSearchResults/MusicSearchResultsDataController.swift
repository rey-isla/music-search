//
//  MusicSearchResultsDataController.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import UIKit

protocol MusicSearchDataControllerDelegate {
    func songsUpdated()
}

class MusicSearchResultsDataController {
    
    // MARK: - Instance Variables
    var delegate: MusicSearchDataControllerDelegate?

    // Delay instantiation of services until needed using lazy variables. Ideally, we should inject this by
    // dependency injection but in interest of expediency, we'll allow the data controller to instantiate its own
    // services.
    private lazy var musicSearchService = MusicSearchService()
    private lazy var imageDownloadService = ImageDownloadService()

    // MARK: - Observed Variables
    var songs: [Song] = [] {
        didSet {
            delegate?.songsUpdated()
        }
    }
    
    // MARK: - Initialization
    init(delegate: MusicSearchDataControllerDelegate?) {
        self.delegate = delegate
    }
}

// MARK: - MusicSearchDataController
extension MusicSearchResultsDataController: MusicSearchDataController {
    
    /// Finds the top 50 songs that matches the passed search word. This will update the currently downloaded song array.
    ///
    /// - Parameters:
    ///     - searchWord: The `String` search term used for the song search
    ///     - completion: The completion block called after the service returns a response. It captures a `Bool`
    ///                   indicating whether the request was successful or not.
    func findSongs(matching searchWord: String, completion: @escaping (Bool) -> ()) {
        musicSearchService.findSongs(matching: searchWord) { [weak self] response in
            switch response {
                case .Error:
                    self?.clearDownloadedSongs()
                    completion(false)
                    return
                case .Success(let songs):
                    self?.songs = songs
                    completion(true)
                    return
            }
        }
    }
    
    /// Finds all songs that matches the passed search word. This will update the currently downloaded song array.
    ///
    /// - Parameters:
    ///     - searchWord: The `String` search term used for the song search
    ///     - completion: The completion block called after the service returns a response. It captures a `Bool`
    ///                   indicating whether the request was successful or not.
    func findAllSongs(matching searchWord: String, completion: @escaping (Bool) -> ()) {
        musicSearchService.findAllSongs(matching: searchWord) { [weak self] response in
            switch response {
                case .Error:
                    self?.clearDownloadedSongs()
                    completion(false)
                    return
                case .Success(let songs):
                    self?.songs = songs
                    completion(true)
                    return
            }
        }
    }
    
    /// Clears all downloaded songs
    func clearDownloadedSongs() {
        songs = []
    }
}

// MARK: - ImageSearchDataController
extension MusicSearchResultsDataController: ImageSearchDataController {
    
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
