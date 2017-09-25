//
//  MusicSearchResultsViewController.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/23/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import UIKit

extension Constants {
    struct MusicSearchResultsViewController {
        static let songDetailCellReuseIdentifier = "SongDetailCell"
        static let showDetailSegueIdentifier = "showDetail"
        static let infiniteScrollOffset = 10
    }
}

protocol MusicSearchDataController {
    var songs: [Song] { get }

    func clearDownloadedSongs()
    func findSongs(matching searchWord: String, completion: @escaping (Bool) -> ())
    func findAllSongs(matching searchWord: String, completion: @escaping (Bool) -> ())
    func downloadImage(from imageUrl: URL, completion: @escaping (UIImage) -> ())
}

protocol ImageSearchDataController {
    func downloadImage(from imageUrl: URL, completion: @escaping (UIImage) -> ())
}

class MusicSearchResultsViewController: UITableViewController {

    // MARK: - Constants
    typealias constants = Constants.MusicSearchResultsViewController

    // MARK: - Instance Variables
    var currentSearchTerm = ""

    // Delay instantiation of dataController until needed using lazy variable. Ideally, we should inject this by
    // dependency injection but in interest of expediency, we'll allow the view controller to instantiate its own
    // dataController.
    private lazy var dataController: MusicSearchDataController & ImageSearchDataController = MusicSearchResultsDataController(delegate: self)

    // MARK: - IBOutlets
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        noResultsLabel.alpha = 0
        activityIndicator.stopAnimating()
        
        super.viewWillAppear(animated)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == constants.showDetailSegueIdentifier {
            guard let detailViewController = (segue.destination as? UINavigationController)?.topViewController as?
                MusicSearchResultDetailViewController, let selectedIndexPath = tableView.indexPathForSelectedRow
                else { return }
            
            if dataController.songs.count > selectedIndexPath.row {
                detailViewController.song = dataController.songs[selectedIndexPath.row]
            }
            
            detailViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            detailViewController.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

// MARK: - TableView Delegate
extension MusicSearchResultsViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        // Automatically download all songs matching the current search term after the user reaches the
        // the set infiniteScrollOffset count. Only allow the update if there are more songs that the
        // API can provide i.e. when songs count is exaclty the defaultResultCount.
        guard dataController.songs.count == Int(Constants.MusicSearchService.defaultResultCount),
            indexPath.row == dataController.songs.count - constants.infiniteScrollOffset else { return }

        // Show indicator that we're downloading new songs
        activityIndicator.startAnimating()
        
        // Find all songs matching the current search term and end the activity indicator regardless of the result.
        dataController.findAllSongs(matching: currentSearchTerm) { success in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Hide the keyboard when a user selects any song
        view.endEditing(true)
    }
}

// MARK: - TableView DataSource
extension MusicSearchResultsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let songDetailCell =
            tableView.dequeueReusableCell(withIdentifier: constants.songDetailCellReuseIdentifier, for: indexPath)
                as? MusicSearchResultsTableViewCell else { return UITableViewCell() }
        
        let cellSong = dataController.songs[indexPath.row]
        
        songDetailCell.songNameLabel?.text = cellSong.name
        songDetailCell.artistNameLabel?.text = cellSong.artistName
        songDetailCell.albumNameLabel?.text = cellSong.albumName
        
        dataController.downloadImage(from: cellSong.albumImageSmallUrl) { image in
            DispatchQueue.main.async { [weak songDetailCell] in
                songDetailCell?.albumImage?.image = image
            }
        }
        
        return songDetailCell
    }
}

// MARK: - MusicSearchDataControllerDelegate
extension MusicSearchResultsViewController: MusicSearchDataControllerDelegate {
    func songsUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}

// MARK: - UISearchBarDelegate
extension MusicSearchResultsViewController: UISearchBarDelegate {
    
    /// Show the No Results UILabel with fade animation.
    private func showNoResultsLabel() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.noResultsLabel.alpha = 1.0
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide keyboard when the search button is clicked
        view.endEditing(true)
        
        // Only allow non-empty search terms
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        
        // Save current search term for infinite scroll
        currentSearchTerm = searchTerm

        // Prepare UI for starting a new search
        dataController.clearDownloadedSongs()
        noResultsLabel.alpha = 0.0
        activityIndicator.startAnimating()
        
        dataController.findSongs(matching: currentSearchTerm) { success in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.activityIndicator.stopAnimating()
                
                guard success else {
                    strongSelf.showNoResultsLabel()
                    return
                }
                
                guard strongSelf.dataController.songs.count > 0 else {
                    strongSelf.showNoResultsLabel()
                    return
                }
            }
        }
    }
}


