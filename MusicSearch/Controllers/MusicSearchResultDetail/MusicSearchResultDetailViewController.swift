//
//  MusicSearchResultDetailViewController.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/23/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import UIKit

class MusicSearchResultDetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var songNameLabel: UILabel?
    @IBOutlet weak var artistNameLabel: UILabel?
    @IBOutlet weak var albumNameLabel: UILabel?
    @IBOutlet weak var albumImageView: UIImageView?
    
    private lazy var lyricsSearchService = LyricsSearchService()
    private lazy var imageDonwloadService = ImageDownloadService()

    var song: Song? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let song = song {
            songNameLabel?.text = song.name
            artistNameLabel?.text = song.artistName
            albumNameLabel?.text = song.albumName
            
            if albumImageView?.image == nil {
                imageDonwloadService.downloadImage(from: song.albumImageLargeUrl) { response in
                    DispatchQueue.main.async { [weak self] in
                        switch response {
                        case .Error(let responseError):
                            return
                        case .Success(let image):
                            self?.albumImageView?.image = image
                            return
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        guard let song = song else { return }
        
        activityIndicator.startAnimating()
        
        lyricsSearchService.findLyrics(of: song.name, by: song.artistName) { [weak self] response in
            
            
            DispatchQueue.main.async { [weak self] in
                defer {
                    self?.activityIndicator.stopAnimating()
                }
                
                guard let strongSelf = self else { return }
                
                //strongSelf.activityIndicator.stopAnimating()
                
                switch response {
                case .Error(let responseError):
                    
//                    UIView.animate(withDuration: 0.2, animations: {
//                        strongSelf.noResultsLabel.alpha = 1.0
//                    })
//
                    return
                case .Success(let lyrics):
                    
                    strongSelf.lyricsTextView.text = lyrics
                    
//                    strongSelf.objects = songs
//
//                    if songs.count == 0 {
//                        UIView.animate(withDuration: 0.2, animations: {
//                            strongSelf.noResultsLabel.alpha = 1.0
//                        })
//                    }
                    
                    return
                }
            }
        }
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}



class ImageDownloadService {
    
    typealias ImageDonwloadResponse = (Response<UIImage>)
    
    //http://lyrics.wikia.com/api.php?func=getSong&artist=taylor+swift&song=Look_What_You_Made_Me_Do&fmt=json
    
    // TODO: Add caching. Use AlamoFire or create convenience extension methods to URLRequest to handle base url,
    // parameeters and other request variables.
    func downloadImage(from imageUrl: URL, completion: @escaping (ImageDonwloadResponse) -> ()) {
        
//        let queryItems = [
//            URLQueryItem(name: "func", value: "getSong"),
//            URLQueryItem(name: "song", value: songName),
//            URLQueryItem(name: "artist", value: artistName),
//            URLQueryItem(name: "fmt", value: "json")
//        ]
//
//        guard let request =
//            URLRequest(requestType: .GET, scheme: "http", host: "lyrics.wikia.com", path: "/api.php",
//                       queryItems: queryItems) else {
//                        completion(.Error(.Parsing))
//                        return
//        }
        
        let request = URLRequest(url: imageUrl)
            
            /*else {
                        completion(.Error(.Parsing))
                        return
        }*/
        
        //request = URLRequest(url: URL(string: "https://itunes.apple.com/search?term=tom+waits&media=music")!)
        
        //request.httpMethod = "GET"
        
        //var lyric = ""
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil, let mimeType = response?.mimeType,
                mimeType.hasPrefix("image") else {                                                 // check for fundamental networking error
                //print("error=\(String(describing: error))")
                completion(.Error(.API(errorMessage: error?.localizedDescription ?? "")))
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                
            }
            
            //TODO: COnvert to do catch
            
            /* let range = welcome.index(welcome.endIndex, offsetBy: -6)..<welcome.endIndex */
            
            // Attempt to handle invalid JSON format by removing any characters before the first curly bracket
            //var stringDataRepresentation = String(data: data, encoding: .utf8)!
        
            
//            if let indexOfFirstCurlyBracket = stringDataRepresentation.index(of: "{") {
//                let invalidJsonStringRangeToRemove = stringDataRepresentation.startIndex..<indexOfFirstCurlyBracket
//                stringDataRepresentation.removeSubrange(invalidJsonStringRangeToRemove)
//            }
//
//            var cleanedData = stringDataRepresentation.replacingOccurrences(of: "'", with: "\"").data(using: .utf8)
//
//            print(stringDataRepresentation)
//
            //welcome.removeSubrange(range)
            
            //let jsonString = stringDataRepresentation.remo
            
            guard let image = UIImage(data: data) else {
                    completion(.Error(.Parsing))
                    return
            }
            
            /*for jsonSong in jsonSongs {
             if let song = Song(json: jsonSong) {
             songs.append(song)
             }
             }*/
            
            completion(.Success(image))
        }
        
        task.resume()
    }
}
