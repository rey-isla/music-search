//
//  MusicSearchResultDetailViewController.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/23/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import UIKit

protocol LyricsSearchDataController {
    func findLyrics(of songName: String, by artistName: String, completion: @escaping (String) -> ())
}

class MusicSearchResultDetailViewController: UIViewController {

    // Delay instantiation of dataController until needed using lazy variable. Ideally, we should inject this by
    // dependency injection but in interest of expediency, we'll allow the view controller to instantiate its own
    // dataController.
    private lazy var dataController: LyricsSearchDataController & ImageSearchDataController =
        MusicSearchResultDetailDataController()

    // MARK: - IBOutlets
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var songNameLabel: UILabel?
    @IBOutlet weak var artistNameLabel: UILabel?
    @IBOutlet weak var albumNameLabel: UILabel?
    @IBOutlet weak var albumImageView: UIImageView?
    
    // MARK: - Observed Variables
    var song: Song? {
        didSet {
            configureView()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the view based on the injected Song
        configureView()
        
        // Only download the lyrics if a non-nil song is injected
        guard let song = song else { return }
        
        activityIndicator.startAnimating()

        dataController.findLyrics(of: song.name, by: song.artistName) { lyrics in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.activityIndicator.stopAnimating()
                strongSelf.lyricsTextView.text = lyrics
            }
        }
    }
    
    // MARK: - UI Update
    
    /// Updates the current UI based on the current song injected to this view controller
    func configureView() {
        guard let song = song else { return }
        
        songNameLabel?.text = song.name
        artistNameLabel?.text = song.artistName
        albumNameLabel?.text = song.albumName
        
        // Only download the album image if the album UIImageView image is not yet set.
        guard albumImageView?.image == nil else { return }
        
        dataController.downloadImage(from: song.albumImageLargeUrl) { image in
            DispatchQueue.main.async { [weak self] in
                self?.albumImageView?.image = image
            }
        }
    }
}
