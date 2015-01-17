//
//  LatestTableViewCell.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/13/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class LatestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var publisherNameLabel: UILabel!
    @IBOutlet weak var publisherIcon: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    var url: NSURL?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        publisherIcon.layer.cornerRadius = 7
        publisherIcon.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
