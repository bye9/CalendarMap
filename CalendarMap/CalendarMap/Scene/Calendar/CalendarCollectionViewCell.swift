//
//  CalendarCollectionViewCell.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 12/8/23.
//

import UIKit

protocol CalendarButtonTappedDelegate: AnyObject {
    func openMapButtonTapped(cell: CalendarCollectionViewCell, id: String, locationName: String, lat: String, lng: String)
}

class CalendarCollectionViewCell: UICollectionViewCell {
    var locationLat: String?
    var locationLng: String?
    var id: String?
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var colorCircle: UIImageView!
    @IBOutlet weak var scheduleName: UILabel!
    @IBOutlet weak var scheduleTime: UILabel!
    @IBOutlet weak var schedulePlace: UILabel!
    
    weak var delegate: CalendarButtonTappedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        parentView.layer.cornerRadius = 10
        parentView.layer.masksToBounds = true
        
        layer.shadowColor = AppStyles.Color.Shadow.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 7
        layer.masksToBounds = false

        
    }
    
    @IBAction func btnOpenOtherApp(_ sender: UIButton) {
        guard let id = id else { return }
        guard let locationName = schedulePlace.text else { return }
        guard let lat = locationLat else { return }
        guard let lng = locationLng else { return }
        
        self.delegate?.openMapButtonTapped(cell: self, id: id, locationName: locationName, lat: lat, lng: lng)
    }
}
