//
//  WeeklyTableCellTableViewCell.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/22.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit

class WeeklyTableCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var summary_label: UIImageView!
    @IBOutlet weak var sunrise_time_label: UILabel!
    @IBOutlet weak var sunset_time_label: UILabel!
    @IBOutlet weak var sunrise_image: UIImageView!
    @IBOutlet weak var sunset_image: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.time_label.text = ""
        self.summary_label.image = UIImage()
        self.sunrise_time_label.text = ""
        self.sunset_time_label.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
