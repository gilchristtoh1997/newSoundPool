//
//  CategoryCell.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 8/24/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var counter: Int = 0
class CategoryCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource
{
    
    var songsArray: [String] = []
    var refHandle : UInt!
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
        return testCount

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
    
    var refHandle: UInt!
    var songsArray: [String] = []
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
        counter = counter + 1
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let imageView : UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "BackGroundHand")
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    func getSongsPlayed(position: Int)
    {
        refHandle = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("My Songs").child("song").observe(.value, with: { (snapshot) in
            var array: [String] = []
            let artistName = UILabel()
            for item in snapshot.children.allObjects as! [DataSnapshot]
            {
                array.append((item.value as? String)!)

            }
            self.songsArray = array
            artistName.text = array[position]
            artistName.textAlignment = .center
            artistName.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(artistName)
            artistName.frame = CGRect(x: 0, y: self.frame.width + 2, width: self.frame.width, height: 40)

        })
    }
    
    
    func setup()
    {
        
        addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        getSongsPlayed(position: counter)
    }
    
}
