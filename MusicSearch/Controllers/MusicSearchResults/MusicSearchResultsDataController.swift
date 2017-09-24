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

class MusicSearchResultsDataController: MusicSearchDataController {
    
    // Delay instantiation of services until it's needed by using lazy variables. Ideally, we should inject this by
    // dependency injection but in interest of expediency, we'll allow the data controller to instantiate its own
    // services.
    private lazy var musicSearchService = MusicSearchService()
    private lazy var imageDownloadService = ImageDownloadService()

    var songs: [Song] = [] {
        didSet {
            delegate?.songsUpdated()
        }
    }
    
    var delegate: MusicSearchDataControllerDelegate?
    
    init(delegate: MusicSearchDataControllerDelegate?) {
        self.delegate = delegate
    }
    
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

    func clearDownloadedSongs() {
        songs = []
    }
}
