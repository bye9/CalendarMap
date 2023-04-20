//
//  SearchTableViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/08.
//

import UIKit

protocol SendCoordinateDelegate {
    func sendCoordinate(x: String, y: String)
    func registerSchedule() // TODO: 여기서 장소 좌표 및 주소 값 등 ViewController로 전달 필요...
}

class SearchTableViewController: UIViewController {
    
    @IBOutlet var tb: UITableView!
    
//    let items = ["1","2","3"]
//    let searchViewModel = SearchViewModel()
    let cellReuseIdentifier = "SearchTableViewCell"
    var locations: KakaoSearchLocation?
//    var locations = SearchLocation(lastBuildDate: "", total: 0, start: 0, display: 0, items: [Item(title: "", link: "", category: "", description: "", telephone: "", address: "", roadAddress: "", mapx: "", mapy: "")])
//    var coordinate = SearchCoordinate(status: "", meta: Meta(totalCount: 0, page: 0, count: 0), addresses: [Address(roadAddress: "", jibunAddress: "", englishAddress: "", addressElements: [AddressElement(types: [""], longName: "", shortName: "", code: "")], x: "", y: "", distance: 0)], errorMessage: "")
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("정환 \(locations)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
        
        cell.locationName.text = locations?.documents[indexPath.row].placeName.htmlEscaped
        
        let roadAddressName = locations?.documents[indexPath.row].roadAddressName ?? ""
        let addressName = locations?.documents[indexPath.row].addressName ?? ""
        cell.locationAddress.text = roadAddressName.count == 0 ? addressName : roadAddressName
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let roadAddressName = locations?.documents[indexPath.row].roadAddressName else { return }
        guard let addressName = locations?.documents[indexPath.row].addressName else { return }
        
        searchViewModel.fetchCoordinate(searchAddress: roadAddressName.count == 0 ? addressName : roadAddressName) { data in
            print("정환 \(data?.addresses[0].y), \(data?.addresses[0].x)")
            self.delegate?.sendCoordinate(x: data?.addresses[0].x ?? "0", y: data?.addresses[0].y ?? "0")
        }
        
        
        
    }
    
}

extension SearchTableViewController: ButtonTappedDelegate {
    // TODO: 셀에서 여기로 장소 좌표 및 주소 값 전달 필요...
    func cellButtonTapped() {
        print("일정등록하기버튼 클릭")
        
        let vc = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "RegisterScheduleViewController")
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
