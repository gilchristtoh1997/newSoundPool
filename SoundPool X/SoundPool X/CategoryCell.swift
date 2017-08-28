//
//  CategoryCell.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 8/24/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import Foundation
import UIKit

class CategoryCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource
{
    let cellID = "appCellID"
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let appCollectionView: UICollectionView =
    {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.backgroundColor = UIColor.clear
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.scrollsToTop = false
        return collectionview
    }()
    let dividerLine: UIView = {
        let view =  UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    func setUpViews()
    {
        backgroundColor = UIColor.clear
        addSubview(appCollectionView)
        addSubview(dividerLine)
        appCollectionView.dataSource = self
        appCollectionView.delegate = self
        
        appCollectionView.register(artistCell.self, forCellWithReuseIdentifier: cellID)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appCollectionView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appCollectionView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0][v1(0.5)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appCollectionView, "v1": dividerLine]))
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 14, 0, 14)
    }
    
}

class artistCell: UICollectionViewCell
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let imageView : UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "BackGroundHand")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    let artistName: UILabel = {
        let label = UILabel()
        label.text = "JY"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.font = UIFont.systemFontSize(12.0)
        return label
    }()
    func setup()
    {
        addSubview(imageView)
        addSubview(artistName)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        artistName.frame = CGRect(x: 0, y: frame.width + 2, width: frame.width, height: 40)
    }
}
