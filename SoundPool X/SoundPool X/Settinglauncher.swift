//
//  Settinglauncher.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/28/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit

class Setting: NSObject {
    let name: String
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}
class SettingsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellID = "cell"
    let cellHeight : CGFloat = 50
    let settings: [Setting] = {
        return [Setting(name: "Vote", imageName: "domain"),Setting(name: "Like", imageName: "ic_person_black_16"),Setting(name: "Cancel", imageName: "ic_public_16")]
    }()
    
    @IBAction func showSettings(_ sender: Any) {
        if let window = UIApplication.shared.keyWindow
        {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
            
            window.addSubview(blackView)
            window.addSubview(collectionView)
            let height: CGFloat = CGFloat(settings.count) * cellHeight
            let y_value = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y_value, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y_value, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            })
        }
    }
    func dismiss()
    {
        UIView.animate(withDuration: 0.5){
            self.blackView.alpha = 0
            if let keyWindow =  UIApplication.shared.keyWindow
            {
                self.collectionView.frame = CGRect(x: 0, y: keyWindow.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SettingCell
        
        let setting = settings[indexPath.item]
        cell.setting = setting
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = settings[indexPath.item]
        print(setting.name)
        dismiss()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 
    }
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellID)
    }
}
