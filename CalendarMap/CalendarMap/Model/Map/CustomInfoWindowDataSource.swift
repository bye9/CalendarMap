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
    var scheduleTitle: String?
    var startDate: String?
    var endDate: String?
    var colorIndex: Int?
    var startTime: String?
    var endTime: String?
    
    init(_ scheduleTitle: String, _ startDate: String, _ endDate: String, _ colorIndex: Int) {
        self.scheduleTitle = scheduleTitle
        self.startDate = startDate
        self.endDate = endDate
        self.colorIndex = colorIndex
    }
    
    func view(with overlay: NMFOverlay) -> UIView {
        guard let infoWindow = overlay as? NMFInfoWindow else { return rootView }
        if rootView == nil {
            rootView = Bundle.main.loadNibNamed("CustomInfoWindowView", owner: nil, options: nil)?.first as? CustomInfoWindowView
        }
        
        self.splitDate(self.startDate!, self.endDate!)
        
        if infoWindow.marker != nil {
            rootView.infoWindowBackground.image = UIImage(named: AppStyles.ColorCircle.backgroundSquare[colorIndex ?? 0])
//            rootView.infoWindowLabel.text = (startTime ?? "") + (endTime ?? "")
            rootView.infoWindowLabel.text = self.scheduleTitle
            rootView.infoWindowLabel.font = UIFont(name: "NotoSansKR-Medium", size: 15)
        }
//        rootView.infoWindowLabel.sizeToFit()
//        let width = rootView.infoWindowLabel.frame.size.width + 80
//        rootView.frame = CGRect(x: 0, y: 0, width: width, height: 88)
//        rootView.layoutIfNeeded()
        
        return rootView
    }
    
    func splitDate(_ startDate: String, _ endDate: String) {
        print(startDate)
        print(endDate)
        
        let startArray = startDate.components(separatedBy: " ")
        startTime = startArray[1] + startArray[2]
        
        let endArray = startDate.components(separatedBy: " ")
        endTime = endArray[1] + endArray[2]
        
        print(startTime)
        print(endTime)
    }
}
