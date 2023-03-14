//
//  SearchTableViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/08.
//

import UIKit

class SearchTableViewController: UIViewController {
    
    @IBOutlet var tb: UITableView!
    
//    let items = ["1","2","3"]
//    let searchViewModel = SearchViewModel()
    let cellReuseIdentifier = "SearchTableViewCell"
    let total = 0
    var locations = SearchLocation(lastBuildDate: "", total: 0, start: 0, display: 0, items: [Item(title: "", link: "", category: "", description: "", telephone: "", address: "", roadAddress: "", mapx: "", mapy: "")])
    
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
        cell.locationName.text = locations.items[indexPath.row].title
//        //        cell.locationName.text = items[indexPath.row]
//        cell.locationAddress.text = items[indexPath.row]
        
        return cell
    }
    
    
}
