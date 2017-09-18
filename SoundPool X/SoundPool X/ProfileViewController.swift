//
//  ProfileViewController.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/9/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit
import Firebase


class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    var refHandle : UInt!
    var cell: CategoryCell!
    var songsArray: [String] = []
    
    @IBOutlet var profile_navigation: UINavigationItem!

    @IBOutlet var collectionview: UICollectionView!

    var recentPlaysButton: UIButton = {
        let rp = UIButton()
        rp.setTitle("Recent Plays", for: .normal)
        rp.setTitleColor(UIColor.lightGray, for: .normal)
        rp.titleLabel?.textAlignment = .center
        rp.addTarget(self, action: #selector(recentPlays), for: .touchUpInside)
        return rp
    }()
    let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        recentPlaysButton.frame = CGRect(x: 0, y: collectionview.frame.origin.y + collectionview.frame.height, width: self.view.frame.size.width, height: 50)
        recentPlaysButton.layer.borderColor = UIColor.lightGray.cgColor
        recentPlaysButton.layer.borderWidth = 1
        self.view.addSubview(recentPlaysButton)
        
        collectionview.layer.borderWidth = 1
        collectionview.layer.borderColor = UIColor.lightGray.cgColor
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.scrollsToTop = false
        collectionview.isScrollEnabled = false
        collectionview?.register(CategoryCell.self, forCellWithReuseIdentifier: cellID)
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                self.profile_navigation.title = dictionary["username"] as? String
            }
        }, withCancel: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func recentPlays()
    {
        print("hi")
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryCell

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
}

