//
//  ProfileViewController.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/9/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {


    @IBOutlet var profile_navigation: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

   
}
