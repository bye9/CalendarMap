//
//  SearchTableViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/08.
//

import UIKit

class SearchTableViewController: UIViewController {
    
    @IBOutlet var tb: UITableView!
    
    var items = ["item1", "item2", "item3"]
    let cellReuseIdentifier = "SearchTableViewCell"
    
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
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SearchTableViewCell
        cell.locationName.text = items[indexPath.row]
        cell.locationAddress.text = items[indexPath.row]
        
        return cell
    }
    
    
}
