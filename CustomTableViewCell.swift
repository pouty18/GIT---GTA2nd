//
//  CustomTableViewCell.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/20/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellNumberLabel: UILabel!
    
    @IBOutlet weak var cellGameNameLabel: UILabel!
    
    @IBOutlet weak var cellGameDetailLabel: UILabel!
    
    @IBOutlet weak var cellPicPlaceholder: UILabel!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
