//
//  SearchViewController.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/9/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation
import FirebaseAuth

class SearchViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var searchbar: UISearchBar!
    @IBOutlet var myTable: UITableView!
    let showResultsButton = UIButton()
    var playsArray: [String:Int] = [:]
    var refHandle : UInt!
    var count: Int = 0
    let nothingFound = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "searchviewcell", bundle: nil)
        self.tableview.register(nibName, forCellReuseIdentifier: "newCell")
        let nibName2 = UINib(nibName: "searchCell", bundle: nil)
        self.tableview.register(nibName2, forCellReuseIdentifier: "myCell")
        tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        update_number_of_plays()

        print(self.playsArray)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var tableViewResults: [String] = []
    var result: [String] = []
    let blackView = UIView()
    let tableview = UITableView()
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(self.playsArray)
        populateAllResults()
        if self.tableViewResults.count == 0
        {
            print("Sorry nothing found")
        }
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchText)
        tableview.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.myTable
        {
           return tableViewResults.count
        }
        if tableView == self.tableview
        {
            return tableViewResults.count
        }
        else
        {
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tablecell = UITableViewCell()
        if tableView == self.myTable
        {
            /**let plays: String = String(describing: (self.playsArray[self.tableViewResults[indexPath.item]])).replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            
            let curSong: String = tableViewResults[indexPath.item]
            let song = curSong.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+song+".mp3")
            let assets = AVURLAsset(url: url!)
            let audioDuration = assets.duration
            let duration = CMTimeGetSeconds(audioDuration)
            let s: Int = Int(duration) % 60
            let m: Int = Int(duration) / 60
            
            let formattedDuration = String(format: "%0d:%02d", m, s)**/
            
            let viewcell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! searchviewcell
            viewcell.CommonInit(name: self.tableViewResults[indexPath.item], image: UIImage(named: "google")!) //// Get cell's actual image
            count = count + 1
            //String(self.playsArray[indexPath.item])
            return viewcell
        }
        else if tableView == self.tableview
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! searchCell
            cell.getSongTitle(name: self.tableViewResults[indexPath.item])
            return cell
        }
        else
        {
            return tablecell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableview
        {
            return 70
        }
        else
        {
            return 70
        }
        
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        filterContentForSearchText(searchText: searchbar.text!)
        self.tableViewResults.removeAll()
        tableview.reloadData()
        myTable.delegate = self
        myTable.dataSource = self
        let nibName = UINib(nibName: "searchviewcell", bundle: nil)
        myTable.register(nibName, forCellReuseIdentifier: "newCell")
        showResultsButton.setTitle("Show Results", for: .normal)
        showResultsButton.layer.borderWidth = 1
        showResultsButton.layer.borderColor = UIColor.purple.cgColor
        searchBar.showsCancelButton = true
        
        if nothingFound.isHidden == false
        {
            UIView.animate(withDuration: 0.5){
                self.nothingFound.frame = CGRect(x:0, y: Int(self.view.frame.size.height), width: Int(self.searchbar.frame.size.width), height: 0)
                
            }
        }
        
        if let window = UIApplication.shared.keyWindow
        {
            
            tableview.backgroundColor = UIColor.white
            tableview.dataSource = self
            tableview.delegate = self
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            let dismissGes = UITapGestureRecognizer(target: self, action: #selector(self.dismissView))
            blackView.addGestureRecognizer(dismissGes)
            showResultsButton.titleLabel?.textColor = UIColor.black
            //showResultsButton.backgroundColor = UIColor.white
            showResultsButton.frame = CGRect(x: tableview.frame.origin.x, y: (tableview.frame.origin.y + tableview.frame.size.height + 10), width: tableview.frame.size.width, height: 40)

            showResultsButton.addTarget(self, action: #selector(populateAllResults), for: .touchUpInside)

            window.addSubview(blackView)
            window.addSubview(showResultsButton)
            window.addSubview(tableview)
            
            blackView.alpha = 0
            blackView.frame = CGRect(x: 0, y: searchBar.frame.origin.y + searchBar.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
            tableview.frame = CGRect(x:Int(searchBar.frame.origin.x), y: Int(searchBar.frame.origin.y + searchBar.frame.size.height), width: Int(searchBar.frame.size.width), height: Int(self.view.frame.size.height/4))
            showResultsButton.setTitle("Show Results", for: .normal)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                print("that one")
                self.blackView.alpha = 1
                self.tableview.frame = CGRect(x:Int(searchBar.frame.origin.x), y: Int(searchBar.frame.origin.y + searchBar.frame.size.height), width: Int(searchBar.frame.size.width), height: Int(self.view.frame.size.height/4))
                self.showResultsButton.frame = CGRect(x: self.tableview.frame.origin.x, y: (self.tableview.frame.origin.y + self.tableview.frame.size.height), width: self.tableview.frame.size.width, height: 40)
                self.showResultsButton.setTitle("Show Results", for: .normal)
            }, completion: nil)
            UIView.animate(withDuration: 0.5, animations: {
                print("this one")
                self.blackView.alpha = 1
                self.tableview.frame = CGRect(x:Int(searchBar.frame.origin.x), y: Int(searchBar.frame.origin.y + searchBar.frame.size.height), width: Int(searchBar.frame.size.width), height: Int(self.view.frame.size.height/4))
                self.showResultsButton.frame = CGRect(x: self.tableview.frame.origin.x, y: (self.tableview.frame.origin.y + self.tableview.frame.size.height), width: self.tableview.frame.size.width, height: 40)
                self.showResultsButton.setTitle("Show Results", for: .normal)
            })
            
        }
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismissView()
        searchbar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.text = ""

    }
    @objc func dismissView()
    {
        print("in dismis")
        UIView.animate(withDuration: 0.5){
            self.blackView.alpha = 0
            self.tableview.frame = CGRect(x:Int(self.searchbar.frame.origin.x), y: Int(self.searchbar.frame.origin.y + self.searchbar.frame.size.height), width: Int(self.searchbar.frame.size.width), height: 0)
            self.showResultsButton.removeFromSuperview()

        }
        self.view.endEditing(true)
        self.searchbar.text = ""
        self.searchbar.setShowsCancelButton(false, animated: false)
    }
    func filterContentForSearchText(searchText: String)
    {
        if((searchbar.text) == "")
        {
            self.showResultsButton.removeFromSuperview()
            self.tableview.removeFromSuperview()
        }
        self.tableViewResults = list.filter({ (name) -> Bool in
            
            let stringMatch = name.lowercased().range(of: searchText.lowercased())
            return stringMatch != nil ? true : false
            
        })
        
    }
    @objc func populateAllResults()
    {
        
        print("populating all results")
        self.dismissView()
        searchbar.showsCancelButton = false
        searchbar.setShowsCancelButton(false, animated: false)
        searchbar.text = ""
        if self.tableViewResults.count == 0
        {
            nothingFound.backgroundColor = UIColor.white
            nothingFound.frame = CGRect(x: 0, y: Int(searchbar.frame.origin.y + searchbar.frame.height), width: Int(self.view.frame.size.width), height: Int(self.view.frame.size.height))
            let notFoundLabel = UILabel()
            notFoundLabel.frame = CGRect(x: 0, y: Int(searchbar.frame.origin.y + searchbar.frame.height) + 30, width: Int(self.view.frame.size.width), height: 50)
            notFoundLabel.textAlignment = NSTextAlignment.center
            notFoundLabel.text = "Sorry no results found"
            self.view.addSubview(nothingFound)
            nothingFound.addSubview(notFoundLabel)
            print("Sorry nothing found")
        }

        self.myTable.reloadData()
    }
    func update_number_of_plays()
    {
        refHandle = Database.database().reference().child("Songs").observe(.value, with: { (snapshot) in
            print(snapshot)
            var array: [String:Int] = [:]
            for item in snapshot.children.allObjects as! [DataSnapshot]
            {
                if item.key == "Miley Cyrus - Party In The USA"
                {
                    array["Miley Cyrus - Party In The U.S.A."] = item.value as? Int
                    continue
                }
                array[item.key] = item.value as? Int

            }
            self.playsArray = array
            DispatchQueue.main.async(execute: {

                self.myTable.reloadData()
                //self.count = self.count + 1

            })
            print(self.playsArray)
        })
    }
    
  }
