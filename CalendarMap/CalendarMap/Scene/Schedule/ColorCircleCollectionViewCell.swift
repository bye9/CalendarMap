//
//  ColorCircleCollectionViewCell.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/07/08.
//

import UIKit

class ColorCircleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colorCircleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        colorCircleButton.layer.cornerRadius = colorCircleButton.frame.width / 2
        colorCircleButton.layer.masksToBounds = true
        
        
    }

}
