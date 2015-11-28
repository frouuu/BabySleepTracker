//
//  NapTimeTableViewCell.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 17/11/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import UIKit

class NapTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
