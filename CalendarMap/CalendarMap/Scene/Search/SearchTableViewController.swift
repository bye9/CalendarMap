//
//  SearchTableViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/08.
//

import UIKit

protocol SendCoordinateDelegate {
    func sendCoordinate(lat: String, lng: String)
}

class SearchTableViewController: UIViewController {
    
    @IBOutlet var tb: UITableView!
    
    let cellReuseIdentifier = "SearchTableViewCell"
    var locations: KakaoSearchLocation?
    var searchViewModel = SearchViewModel()
    var delegate: SendCoordinateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "SearchTableViewCell", bundle: nil)
        tb.register(nibName, forCellReuseIdentifier: cellReuseIdentifier)
        tb.dataSource = self
        tb.delegate = self
        tb.isHidden = locations?.documents.count == 0 ? true : false
    }
}

extension SearchTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations?.documents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
        let categoryName = locations?.documents[indexPath.row].categoryName.components(separatedBy: "> ").last ?? ""
        cell.locationName.text = locations?.documents[indexPath.row].placeName
        cell.locationCategory.text = categoryName
        
        let distanceMeter = Double(locations?.documents[indexPath.row].distance ?? "")
        if distanceMeter! >= 1000 {
            var distanceKiloMeter = String(format: "%.1f", distanceMeter! / 1_000.0)
            if distanceKiloMeter.last == "0" {
                distanceKiloMeter = String(Int(Double(distanceKiloMeter)!))
            }
            cell.locationDistance.text = distanceKiloMeter + "km"
        } else {
            cell.locationDistance.text = String(Int(distanceMeter!)) + "m"
        }
        
        let roadAddressName = locations?.documents[indexPath.row].roadAddressName ?? ""
        let addressName = locations?.documents[indexPath.row].addressName ?? ""
        cell.locationAddress.text = addressName
        cell.locationRoadAddress = roadAddressName
        cell.locationLat = locations?.documents[indexPath.row].y
        cell.locationLng = locations?.documents[indexPath.row].x
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let addressName = locations?.documents[indexPath.row].addressName else { return }
        
        searchViewModel.fetchCoordinate(searchAddress: addressName) { data in
//            print("정환 \(data?.addresses[0].y), \(data?.addresses[0].x)")
            self.delegate?.sendCoordinate(lat: data?.addresses[0].y ?? "0", lng: data?.addresses[0].x ?? "0")
        }

    }
}

extension SearchTableViewController: ButtonTappedDelegate {
    // TODO: 셀에서 여기로 장소 좌표 및 주소 값 전달 필요...
    func cellButtonTapped(name: String, address: String, roadAddress: String, lat: String, lng: String) {
        print("일정등록하기버튼 클릭")
        print(name, lat, lng)
        
        guard let registerScheduleViewController = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "RegisterScheduleViewController") as? RegisterScheduleViewController else { return }
        registerScheduleViewController.locationName = name
        registerScheduleViewController.address = address
        registerScheduleViewController.roadAddress = roadAddress
        registerScheduleViewController.lat = lat
        registerScheduleViewController.lng = lng
        
        registerScheduleViewController.completionHandler = {
            print($0, $1)
            self.delegate?.sendCoordinate(lat: $0, lng: $1)
            
        }
        
        self.navigationController?.pushViewController(registerScheduleViewController, animated: true)
    }
}

extension String {
    // html 태그 제거 + html entity들 디코딩.
    var htmlEscaped: String {
        guard let encodedData = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributed = try NSAttributedString(data: encodedData,
                                                    options: options,
                                                    documentAttributes: nil)
            return attributed.string
        } catch {
            return self
        }
    }
}
