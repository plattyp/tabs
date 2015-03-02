//
//  ContactListCell.swift
//  tabs
//
//  Created by Andrew Platkin on 2/14/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import UIKit

class ContactListCell: UITableViewCell {
    
    //Row Outlets
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var dateLastContactedLabel: UILabel!
    @IBOutlet weak var daysSinceLastContactedLabel: UILabel!
    @IBOutlet weak var daysUnderLabel: UILabel!
    @IBOutlet weak var daysBackgroundBlock: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    func setup() {
        //Round out corners on background block
        daysBackgroundBlock.layer.cornerRadius = 8
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
}
