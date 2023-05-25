//
//  CustomInfoWindowDataSource.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/05/15.
//

import UIKit
import NMapsMap

class CustomInfoWindowDataSource: NSObject, NMFOverlayImageDataSource {
    var rootView: CustomInfoWindowView!
    
    func view(with overlay: NMFOverlay) -> UIView {
        guard let infoWindow = overlay as? NMFInfoWindow else { return rootView }
        if rootView == nil {
            rootView = Bundle.main.loadNibNamed("CustomInfoWindowView", owner: nil, options: nil)?.first as? CustomInfoWindowView
        }
        
        if infoWindow.marker != nil {
            rootView.infoWindowBackground.image = UIImage(named: "scheduleSquareRed")
            rootView.infoWindowLabel.text = "11:00 - 12:00"
            rootView.infoWindowLabel.font = UIFont(name: "NotoSansKR-Medium", size: 15)
        }
//        rootView.textLabel.sizeToFit()
//        rootView.frame = CGRect(x: 0, y: 0, width: self.rootView.frame.width, height: self.rootView.frame.height)
//        rootView.layoutIfNeeded()

        
        return rootView
    }
}
