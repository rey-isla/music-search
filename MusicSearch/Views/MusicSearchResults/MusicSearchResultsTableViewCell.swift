//
//  MusicSearchResultsTableViewCell.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/23/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import UIKit

// Note: If this table view cell will be re-used elsewhere in the app, convert it into its own nib to allow reuse.
class MusicSearchResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumImage: UIImageView?
    @IBOutlet weak var songNameLabel: UILabel?
    @IBOutlet weak var artistNameLabel: UILabel?
    @IBOutlet weak var albumNameLabel: UILabel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        songNameLabel?.text = ""
        artistNameLabel?.text = ""
        albumNameLabel?.text = ""
        albumImage?.image = nil
    }
    
}
