//
//  CalendarCollectionViewCell.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 12/8/23.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var colorCircle: UIImageView!
    @IBOutlet weak var scheduleName: UILabel!
    @IBOutlet weak var scheduleTime: UILabel!
    @IBOutlet weak var schedulePlace: UILabel!
    @IBOutlet weak var scheduleDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        parentView.layer.cornerRadius = 10
        parentView.layer.masksToBounds = true
        
        layer.shadowColor = AppStyles.Color.Shadow.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 14
        layer.masksToBounds = false

        
    }
    
    @IBAction func btnOpenOtherApp(_ sender: UIButton) {
         
    }
    

}
