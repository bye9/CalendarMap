//
//  ColorCircleCollectionViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/07/08.
//

import UIKit

class ColorCircleCollectionViewController: UIViewController {
    let cellReuseIdentifier = "ColorCircleCollectionViewCell"
    let colorImages = ["color_blue", "color_purple", "color_pink", "color_red", "color_orange",
                       "color_yellow", "color_green", "color_lightgreen", "color_gray7", "color_gray3"]
    let colorCheckImages = ["color_check_blue", "color_check_purple", "color_check_pink", "color_check_red", "color_check_orange",
                      "color_check_yellow", "color_check_green", "color_check_lightgreen", "color_check_gray7", "color_check_gray3"]
    var colorIndex = 0
    var completionHandler: ((Int) -> Void)?
    
    @IBOutlet weak var colorSelectCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let nibName = UINib(nibName: "ColorCircleCollectionViewCell", bundle: nil)
        colorSelectCollectionView.register(nibName, forCellWithReuseIdentifier: cellReuseIdentifier)
        colorSelectCollectionView.dataSource = self
        colorSelectCollectionView.delegate = self
    }
}

extension ColorCircleCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? ColorCircleCollectionViewCell else { return UICollectionViewCell() }
        let color = colorImages[indexPath.row]
        cell.colorCircleButton.setImage(UIImage(named: color), for: .normal)
        
        if indexPath.row == colorIndex {
            cell.colorCircleButton.setImage(UIImage(named: colorCheckImages[colorIndex]), for: .normal)
        }
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorIndex = indexPath.row
        collectionView.reloadData()

        completionHandler?(colorIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 29
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
}
