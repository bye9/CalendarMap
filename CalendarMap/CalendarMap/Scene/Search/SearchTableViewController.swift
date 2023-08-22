//
//  SearchTableViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/08.
//

import UIKit

protocol SendCoordinateDelegate {
    func sendCoordinate(lat: String, lng: String)
    func registerSchedule() // TODO: 여기서 장소 좌표 및 주소 값 등 ViewController로 전달 필요...
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
        cell.locationName.text = locations?.documents[indexPath.row].placeName
        let categoryName = locations?.documents[indexPath.row].categoryName.components(separatedBy: "> ").last ?? ""
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
        guard let roadAddressName = locations?.documents[indexPath.row].roadAddressName else { return }
        guard let addressName = locations?.documents[indexPath.row].addressName else { return }
        
        searchViewModel.fetchCoordinate(searchAddress: addressName) { data in
            print("정환 \(data?.addresses[0].y), \(data?.addresses[0].x)")
            self.delegate?.sendCoordinate(lat: data?.addresses[0].y ?? "0", lng: data?.addresses[0].x ?? "0")
        }
        
        
        
    }
    
}

extension SearchTableViewController: ButtonTappedDelegate {
    
    // TODO: 셀에서 여기로 장소 좌표 및 주소 값 전달 필요...
    func cellButtonTapped(name: String, address: String, roadAddress: String, lat: String, lng: String) {
        print("일정등록하기버튼 클릭")
        print(name, lat, lng)
        
        guard let vc = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "RegisterScheduleViewController") as? RegisterScheduleViewController else { return }
        vc.locationName = name
        vc.address = address
        vc.roadAddress = roadAddress
        vc.lat = lat
        vc.lng = lng
        
        vc.completionHandler = {
            print($0, $1)
            self.delegate?.sendCoordinate(lat: $0, lng: $1)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
        // TODO: 테이블뷰 검색결과 남겨두고 일정등록화면 갔다올 것인가, 아닌가
//        self.delegate?.registerSchedule()

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
