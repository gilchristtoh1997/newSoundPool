//
//  SignUpViewController.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/8/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var FullName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func createAccountAction(_ sender: Any) {
        if emailAddress.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().createUser(withEmail: emailAddress.text!, password: password.text!) { (user, error) in
                
                reference = Database.database().reference(fromURL: "https://soundpool-x.firebaseio.com/")
                
                let usersRef = reference?.child("users").child((user?.uid)!)
                
                let values = ["fullname": self.FullName.text, "username":self.username.text, "email": self.emailAddress.text]
                
                usersRef?.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                    if err != nil
                    {
                        print(err!)
                        return
                    }
                    else
                    {
                        print("user saved succesfully")
                    }
                })
                
                if error == nil {
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                    self.present(vc!, animated: true, completion: nil)
                    
                }
                else
                {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
