//
//  ColorCircleCollectionViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/07/08.
//

import UIKit

class ColorCircleCollectionViewController: UIViewController {
    let cellReuseIdentifier = "ColorCircleCollectionViewCell"

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
        let color = AppStyles.ColorCircle.colorImages[indexPath.row]
        cell.colorCircleButton.setImage(UIImage(named: color), for: .normal)
        
        if indexPath.row == colorIndex {
            cell.colorCircleButton.setImage(UIImage(named: AppStyles.ColorCircle.colorCheckImages[colorIndex]), for: .normal)
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
