//
//  SearchTableViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/08.
//

import UIKit

protocol SendCoordinateDelegate {
    func sendCoordinate(x: String, y: String)
}

class SearchTableViewController: UIViewController {
    
    @IBOutlet var tb: UITableView!
    
//    let items = ["1","2","3"]
//    let searchViewModel = SearchViewModel()
    let cellReuseIdentifier = "SearchTableViewCell"
    var locations = SearchLocation(lastBuildDate: "", total: 0, start: 0, display: 0, items: [Item(title: "", link: "", category: "", description: "", telephone: "", address: "", roadAddress: "", mapx: "", mapy: "")])
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
        return locations.total
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("정환 \(locations)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SearchTableViewCell
        cell.locationName.text = locations.items[indexPath.row].title.htmlEscaped
        cell.locationAddress.text = locations.items[indexPath.row].address
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchViewModel.fetchCoordinate(searchAddress: locations.items[indexPath.row].address) { data in
            print("정환 %@, %@", data?.addresses[0].y, data?.addresses[0].x)
            self.delegate?.sendCoordinate(x: data?.addresses[0].x ?? "0", y: data?.addresses[0].y ?? "0")
        }
        
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
