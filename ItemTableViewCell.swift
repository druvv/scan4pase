//
//  ItemTableViewCell.swift
//  scan4PASE
//
//  Created by Dhruv Sringari on 3/16/15.
//  Copyright (c) 2015 Sringari Worldwide. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet var skuLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var retailCostLabel: UILabel!
    @IBOutlet var iboCostLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
