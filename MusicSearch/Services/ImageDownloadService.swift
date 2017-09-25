//
//  ImageDownloadService.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import UIKit

extension Constants {
    struct ImageDownloadService {
        static let invalidResponse = NSLocalizedString("Data is not an image.", comment: "")
    }
}

class ImageDownloadService {
    
    // MARK: - Constants/Type Aliases
    typealias constants = Constants.ImageDownloadService
    typealias ImageDownloadResponse = (Response<UIImage>)
    
    /// Downloads the image from the passed image URL.
    ///
    /// - Parameters:
    ///     - imageUrl: The `URL` of the requested image
    ///     - completion: The completion block called after the server returns a response. It captures a `UIImage`
    ///                   created from the server response.
    func downloadImage(from imageUrl: URL, completion: @escaping (ImageDownloadResponse) -> ()) {
        
        let request = URLRequest(url: imageUrl)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.Error(.API(errorMessage: error?.localizedDescription ?? "")))
                return
            }
            
            guard let mimeType = response?.mimeType, mimeType.hasPrefix("image") else {
                completion(.Error(.API(errorMessage: constants.invalidResponse)))
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                completion(.Error(.API(errorMessage: Constants.Response.invalidStatusCode)))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.Error(.Parsing))
                return
            }
            
            completion(.Success(image))
        }.resume()
    }
}
