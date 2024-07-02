//
//  CalendarCollectionViewCell.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 12/8/23.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var colorCircle: UIImageView!
    @IBOutlet weak var scheduleName: UILabel!
    @IBOutlet weak var scheduleTime: UILabel!
    @IBOutlet weak var schedulePlace: UILabel!
    @IBOutlet weak var scheduleDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        contentView.layer.cornerRadius = 10
//        contentView.layer.masksToBounds = true
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: -2, height: 2)
        self.layer.shadowRadius = 14
        
    }
    
    @IBAction func btnOpenOtherApp(_ sender: UIButton) {
         
    }
    

}
