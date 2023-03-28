//
//  SearchTableViewCell.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/10.
//

import UIKit

protocol ButtonTappedDelegate: AnyObject {
    func cellButtonTapped()
}

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet var locationName: UILabel!
    @IBOutlet var locationAddress: UILabel!
    
    weak var delegate: ButtonTappedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func registerScheduleTapped(_ sender: UIButton) {
        delegate?.cellButtonTapped()
    }
    
}
