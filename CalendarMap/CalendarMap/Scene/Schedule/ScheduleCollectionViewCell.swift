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
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 5
        self.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 14
        
//        colorCircle.layer.cornerRadius = colorCircle.frame.width / 2
//        colorCircle.layer.masksToBounds = true
        
    }

}
