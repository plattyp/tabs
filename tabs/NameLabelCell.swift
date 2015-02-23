//
//  NameLabelCell.swift
//  tabs
//
//  Created by Andrew Platkin on 2/21/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import UIKit

class NameLabelCell: UITableViewCell {


    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
