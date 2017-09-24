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
    }
}

protocol MusicSearchDataController {
    var songs: [Song] { get }

    func clearDownloadedSongs()
    func findSongs(matching searchWord: String, completion: @escaping (Bool) -> ())
    func findAllSongs(matching searchWord: String, completion: @escaping (Bool) -> ())
    func downloadImage(from imageUrl: URL, completion: @escaping (UIImage) -> ())
}

class MusicSearchResultsViewController: UITableViewController {

    typealias constants = Constants.MusicSearchResultsViewController

    var detailViewController: MusicSearchResultDetailViewController? = nil
    var currentSearchTerm = ""

    private lazy var dataController: MusicSearchDataController = MusicSearchResultsDataController(delegate: self)
    
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? MusicSearchResultDetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        noResultsLabel.alpha = 0
        activityIndicator.stopAnimating()
        
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let detailViewController = (segue.destination as? UINavigationController)?.topViewController as? MusicSearchResultDetailViewController else { return }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                //let object = objects[indexPath.row] as! NSDate
                //let controller = (segue.destination as! UINavigationController).topViewController as! MusicSearchResultDetailViewController
                //controller.detailItem = object
                
                if dataController.songs.count > indexPath.row {
                    detailViewController.song = dataController.songs[indexPath.row]
                }
                
                detailViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                detailViewController.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

extension MusicSearchResultsViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if dataController.songs.count == 50 {
            if indexPath.row == dataController.songs.count - 10 { //you might decide to load sooner than -1 I guess...
                //load more into data here
                
                activityIndicator.startAnimating()
                
                dataController.findAllSongs(matching: currentSearchTerm) { success in
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
}

extension MusicSearchResultsViewController {
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let songDetailCell =
            tableView.dequeueReusableCell(withIdentifier: constants.songDetailCellReuseIdentifier,
                                          for: indexPath) as? MusicSearchResultsTableViewCell else {
                                            return UITableViewCell()
        }
        
        songDetailCell.songNameLabel?.text = dataController.songs[indexPath.row].name
        songDetailCell.artistNameLabel?.text = dataController.songs[indexPath.row].artistName
        songDetailCell.albumNameLabel?.text = dataController.songs[indexPath.row].albumName
        
        dataController.downloadImage(from: dataController.songs[indexPath.row].albumImageSmallUrl) { image in
            DispatchQueue.main.async { [weak songDetailCell] in
                songDetailCell?.albumImage?.image = image
            }
        }
        
        return songDetailCell
    }
}

extension MusicSearchResultsViewController: MusicSearchDataControllerDelegate {
    func songsUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}

extension MusicSearchResultsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        
        dataController.clearDownloadedSongs()
        
        noResultsLabel.alpha = 0.0
        activityIndicator.startAnimating()
        
        currentSearchTerm = searchTerm
        
        dataController.findSongs(matching: currentSearchTerm) { success in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.activityIndicator.stopAnimating()
                
                guard success else {
                    UIView.animate(withDuration: 0.2, animations: {
                        strongSelf.noResultsLabel.alpha = 1.0
                    })
                    return
                }
                
                guard strongSelf.dataController.songs.count > 0 else {
                    UIView.animate(withDuration: 0.2, animations: {
                        strongSelf.noResultsLabel.alpha = 1.0
                    })
                    return
                }
            }
        }
    }
}


