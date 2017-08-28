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


    @IBOutlet var profile_navigation: UINavigationItem!
    var refHandle : UInt!
    var songsArray: [String] = []

    @IBOutlet var collectionview: UICollectionView!

    let cellID = "cellID"
    //var hScroll = HorizontalScroll()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        getMySongs()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryCell
        //cell.backgroundColor = UIColor.red
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
    /**func numberofScrollViewElements() -> Int {
        return 10
    }
    func elementAtScrollViewIndex(index: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let button = UIButton()
        button.frame = view.frame
        button.setTitle("hello \(index)", for: .normal)
        button.backgroundColor = UIColor.red
        view.addSubview(button)
        return view
    }*/
    func getMySongs()
    {
        refHandle = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("My Songs").child("song").observe(.value, with: { (snapshot) in
            print(snapshot)
            var array: [String] = []
            for item in snapshot.children.allObjects as! [DataSnapshot]
            {

                array.append((item.value as? String)!)
                
            }
            self.songsArray = array
            DispatchQueue.main.async(execute: {
                
                //self.myTable.reloadData()
                //self.count = self.count + 1
                
            })
            print(self.songsArray)
        })

    }
   
}

