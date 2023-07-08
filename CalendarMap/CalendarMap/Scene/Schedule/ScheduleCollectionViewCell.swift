//
//  ScheduleCollectionViewCell.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/07/08.
//

import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var colorCircle: UIImageView!
    @IBOutlet weak var scheduleName: UILabel!
    @IBOutlet weak var scheduleTime: UILabel!
    @IBOutlet weak var schedulePlace: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        colorCircle.layer.cornerRadius = colorCircle.frame.width / 2
        colorCircle.layer.masksToBounds = true
        
    }

}
