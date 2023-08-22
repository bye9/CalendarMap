//
//  SearchTableViewCell.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/10.
//

import UIKit

protocol ButtonTappedDelegate: AnyObject {
    func cellButtonTapped(name: String, address: String, roadAddress: String, lat: String, lng: String)
}

class SearchTableViewCell: UITableViewCell {
    var locationRoadAddress: String?
    var locationLat: String?
    var locationLng: String?
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationCategory: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var registerScheduleView: UIStackView!

    weak var delegate: ButtonTappedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(registerScheduleTapped))
        registerScheduleView.addGestureRecognizer(tapGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func registerScheduleTapped(_ sender: UITapGestureRecognizer) {
        delegate?.cellButtonTapped(name: locationName.text ?? "장소 이름", address: locationAddress.text ?? "지번 주소", roadAddress: locationRoadAddress ?? "도로명 주소", lat: locationLat ?? "0", lng: locationLng ?? "0")
    }
    
}
