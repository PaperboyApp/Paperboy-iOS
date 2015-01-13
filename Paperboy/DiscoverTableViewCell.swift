//
//  DiscoverTableViewCell.swift
//  Paperboy
//
//  Created by Mario Encina on 1/13/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {

    @IBOutlet weak var publisherIcon: UIImageView!
    @IBOutlet weak var publisherName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
