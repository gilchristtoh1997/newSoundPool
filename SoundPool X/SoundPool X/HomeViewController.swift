//
//  HomeViewController.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/8/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation
import FirebaseAuth

struct cellData
{
    let cell : Int!
    let text : String!
    let length: String!
    let image : UIImage!
}
var cellArray : [AvailableTableViewCell] = []
public var AudioPlayer =  AVPlayer()
public var SelectedSongNumber = Int()
var playerSlider = UISlider()
var scrollView = UIScrollView()
var pauseButton = UIButton()
var gestureRecognizer = UIPanGestureRecognizer()
var toolBarPauseButton = UIButton()
var songImageView = UIImageView()
let SongLabel = UILabel()
var currentSong : String!
var playing = 1
var paused = 0
var playControl = 0
var songsPlayed = 0
var reference:DatabaseReference?
var userSongs: [String] = []
var likesArray: [Int] = []
var testCount: Int = 0
var item_reference : String = ""
let list: [String] = ["Halsey - Colors", "Kygo - It Aint Me", "Martin Garrix & Dua Lipa - Scared To Be Lonely", "Miley Cyrus - Party In The U.S.A.", "The Goodnight - I Will Wait"]


class HomeViewController: UITableViewController, UITabBarControllerDelegate{
    
    @IBOutlet var myTableview: UITableView!
    var refHandle : UInt!
    var selectedSong = AvailableTableViewCell()
    var arrayOfCellData = [cellData]()
    var song_length_array:[String] = []
    var play_array: [Int] = []
    let cellSpacingHeight: CGFloat = 0
    var currSongPlays: Int = 1
    var cell: AvailableTableViewCell!
    let celly = Bundle.main.loadNibNamed("AvailableTableViewCell", owner: self, options: nil)?.first as! AvailableTableViewCell
    var playCount = 0
    var backgroundImage: UIImageView!
    var refresher: UIRefreshControl!
    var Halsey = 0
    var kygo = 0
    var martin = 0
    var miley = 0
    var goodnight = 1
    var count: Int = 0
    var blackview: UIView!
    let toolbar = UIToolbar()
    let dimView = UIView()
    var pauseImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update_number_of_plays()
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refresher)
        
        tableView.register(AvailableTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        myTableview.dataSource = self
        myTableview.delegate = self
        let nibName = UINib(nibName: "AvailableTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "tableviewcell")
        myTableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 108, right: 0)
        
        if Auth.auth().currentUser?.uid == nil
        {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        for item in list
        {
            let song = item.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+song+".mp3")
            let assets = AVURLAsset(url: url!)
            let audioDuration = assets.duration
            let duration = CMTimeGetSeconds(audioDuration)
            let s: Int = Int(duration) % 60
            let m: Int = Int(duration) / 60

            let formattedDuration = String(format: "%0d:%02d", m, s)
            song_length_array.append(formattedDuration)
        }
        getSongsPlayedCount()
    }
    func getSongsPlayedCount()
    {
        refHandle = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("My Songs").child("song").observe(.value, with: { (snapshot) in
            var array: [String] = []
            DispatchQueue.main.async(execute: { 
                for item in snapshot.children.allObjects as! [DataSnapshot]
                {
                    testCount = testCount + 1
                    print("testCount: ",testCount)
                    array.append((item.value as? String)!)
                    
                }
            })
            
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcell", for: indexPath) as! AvailableTableViewCell
        if self.play_array.isEmpty == false
        {
            self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
            self.cell.backgroundColor = UIColor.white
            self.cell.preservesSuperviewLayoutMargins = false
            self.cell.separatorInset = UIEdgeInsets.zero
            self.cell.layoutMargins = UIEdgeInsets.zero
            self.cell.commonInit(UIImage(named: list[indexPath.item])!, title: list[indexPath.item], length: song_length_array[indexPath.item], plays: String(self.play_array[indexPath.item]))
        }
        return cell
            
        
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 200
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let cell  = myTableview.cellForRow(at: indexPath) as! AvailableTableViewCell
        let storyboard = self.storyboard
        let tc = storyboard?.instantiateViewController(withIdentifier: "Home") as! UITabBarController
        reference = Database.database().reference(fromURL: "https://soundpool-x.firebaseio.com/")
        let vc = storyboard?.instantiateViewController(withIdentifier: "playing")
        
        songsPlayed = songsPlayed + 1
        currentSong = list[(indexPath.item)]
        selectedSong = cell
        //updateUserSelectedSongs()

        SongLabel.frame = CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: 80)
        SongLabel.textAlignment = NSTextAlignment.center
        SongLabel.text = list[(indexPath.item)]
        vc?.view.addSubview(createTabBarFrame())
        vc?.tabBarItem.image = UIImage(named: "google")
        vc?.tabBarItem.title = "Playing"
        vc?.view.addSubview(createFrameBackground(image: cell.SongImageView.image!))
        vc?.view.addSubview(SongLabel)
        vc?.view.addSubview(createPauseButton())
        vc?.view.addSubview(createBackButton())
        vc?.view.addSubview(createForwardButton())
        vc?.view.addSubview(createHideButton())
        vc?.view.addSubview(createSlider())
        tc.addChildViewController(vc!)

        
        setupPlayerBar(song: currentSong)
        playSong(cSong: currentSong)

    }
    func playSong(cSong: String)
    {
        print("playing ",cSong)
        let song = cSong.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+song+".mp3")
        
        let playerItem = AVPlayerItem(url: url!)
        AudioPlayer = AVPlayer(playerItem:playerItem)
        AudioPlayer.play()
        playControl = playing
        
        NotificationCenter.default.addObserver(self, selector: #selector(songEnded(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: AudioPlayer.currentItem)    }
    

    var player: playerBar = {
        let pb = playerBar()
        return pb
        
    }()
    private func setupPlayerBar(song: String){
        if let window = UIApplication.shared.keyWindow
        {
            let sb = self.storyboard
            
            let tc = sb?.instantiateViewController(withIdentifier: "Home") as! UITabBarController
            
            print(tc.tabBar.frame.origin.y)
            let frameWidth: Int = Int(self.view.frame.size.width)
            window.addSubview(toolbar)
            //toolbar.translatesAutoresizingMaskIntoConstraints = false
            
            toolbar.frame = CGRect(x: 0, y: Int(window.frame.size.height - 78), width: frameWidth, height: 30)
            toolbar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchingToolbar)))
            
            
            //toolbar.topAnchor.constraint(equalTo: window.bottomAnchor, constant: 20).isActive = true
           toolbar.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 20).isActive = true
            //let cs = NSLayoutConstraint(item: toolbar, attribute:.bottom, relatedBy: .equal, toItem: tableView, attribute: .bottom, multiplier: 1.0, constant: 0)
            //window.addConstraint(cs)
            pauseImage = UIImage(named: "pause")!
            toolBarPauseButton = UIButton(frame: CGRect(x: toolbar.frame.size.width - 140, y: 0, width: 50, height: toolbar.frame.size.height))
            toolBarPauseButton.backgroundColor = UIColor.white
            toolBarPauseButton.setImage(pauseImage, for: .normal)
            toolBarPauseButton.addTarget(self, action: #selector(pausePlayAction), for: .touchUpInside)
            
            let forwardButton: UIButton = UIButton(frame: CGRect(x: toolbar.frame.size.width - 70, y: 0, width: 80, height: toolbar.frame.size.height))
            forwardButton.backgroundColor = UIColor.white
            forwardButton.setImage(UIImage(named: "forward"), for: .normal)
            forwardButton.addTarget(self, action: #selector(forwardAction(_:)), for: .touchUpInside)
            
            SongLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 200, height: toolbar.frame.size.height)
            SongLabel.textAlignment = NSTextAlignment.center
            SongLabel.text = song
            
            toolbar.addSubview(SongLabel)
            toolbar.addSubview(forwardButton)
            toolbar.addSubview(toolBarPauseButton)
            

            if toolbar.isHidden
            {
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.toolbar.frame = CGRect(x: 0, y: Int(self.view.frame.size.height - 78), width: frameWidth, height: 30)
                    
                }, completion: nil)
                UIView.animate(withDuration: 1.0, animations: {
                    self.toolbar.frame = CGRect(x: 0, y: Int(self.view.frame.size.height - 78), width: frameWidth, height: 30)
                    
                })
            }

        }
    }
    
    @objc func touchingToolbar()
    {
        UIView.animate(withDuration: 0.5) {
            if let screenWindow = UIApplication.shared.keyWindow
            {
                self.dimView.backgroundColor = UIColor(white: 0, alpha: 0.5)
                screenWindow.addSubview(self.dimView)
                self.dimView.alpha = 1
                self.dimView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                scrollView = UIScrollView(frame: CGRect(x: 0, y: 150, width: self.view.frame.size.width, height: self.view.frame.size.height))
                scrollView.backgroundColor = UIColor.white
                gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.dismissScroll))
                scrollView.addGestureRecognizer(gestureRecognizer)
                songImageView = UIImageView(frame: CGRect(x: 100, y: 20 , width: 200, height: 200))
                songImageView.image = self.selectedSong.SongImageView.image
                
                playerSlider = UISlider(frame: CGRect(x: 10, y: (scrollView.frame.size.height) - 300, width: scrollView.frame.size.width - 10, height: 80))
                let audioSession = AVAudioSession.sharedInstance()
                let volume: Int = Int(audioSession.outputVolume)
                playerSlider.isContinuous = true
                playerSlider.setValue(Float(volume), animated: false)
                playerSlider.minimumValue = 0
                playerSlider.maximumValue = 10
                playerSlider.addTarget(self, action: #selector(self.controlVolume(_:)), for: .valueChanged)
                
                let BarPauseButton: UIButton = UIButton(frame: CGRect(x: scrollView.frame.size.width - 200, y: (scrollView.frame.size.height) - 230, width: 50, height: 70))
                BarPauseButton.backgroundColor = UIColor.white
                BarPauseButton.setImage(toolBarPauseButton.currentImage, for: .normal) /////// Get the toolbar pause button current text
                BarPauseButton.addTarget(self, action: #selector(self.pausePlayAction), for: .touchUpInside)
                
                let forwardButton: UIButton = UIButton(frame: CGRect(x: scrollView.frame.size.width - 70, y: (scrollView.frame.size.height) - 230, width: 80, height: 70))
                forwardButton.backgroundColor = UIColor.white
                forwardButton.setImage(UIImage(named: "forward"), for: .normal)
                forwardButton.addTarget(self, action: #selector(self.forwardAction(_:)), for: .touchUpInside)
                
                
                let songLabel = UILabel()
                songLabel.frame = CGRect(x: 0, y: (scrollView.frame.size.height) - 375, width: scrollView.frame.size.width, height: 70)
                songLabel.textAlignment = NSTextAlignment.center
                songLabel.text = self.selectedSong.SongTitle.text
                
                let backButton: UIButton = UIButton(frame: CGRect(x: scrollView.frame.size.width - 350, y: (scrollView.frame.size.height) - 230, width: 80, height: 70))
                backButton.backgroundColor = UIColor.white
                backButton.setImage(UIImage(named: "back"), for: .normal)
                backButton.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
                
                scrollView.addSubview(backButton)
                scrollView.addSubview(BarPauseButton)
                scrollView.addSubview(forwardButton)
                scrollView.addSubview(songLabel)
                scrollView.addSubview(playerSlider)
                scrollView.addSubview(songImageView)
                screenWindow.addSubview(scrollView)
            }
        }
    }
    @objc func dismissScroll()
    {
        let velocity = gestureRecognizer.velocity(in: scrollView)
        
        if velocity.y > 30 {
            UIView.animate(withDuration: 0.5){
                if let keyWindow =  UIApplication.shared.keyWindow
                {
                    self.dimView.alpha = 0
                    scrollView.frame = CGRect(x: 0, y: keyWindow.frame.height, width: scrollView.frame.width, height: scrollView.frame.height)
                    toolBarPauseButton.setTitle(toolBarPauseButton.currentTitle, for: .normal)
                }
            }
        }

    }
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for(index, view) in views.enumerated()
        {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }

    //refreshes the home page
    @objc func refresh()
    {
        self.viewDidLoad()
        refresher.endRefreshing()
    }
    func update_number_of_plays()
    {
        refHandle = Database.database().reference().child("Songs").observe(.value, with: { (snapshot) in
            print(snapshot)
            var array: [Int] = []
            for item in snapshot.children.allObjects as! [DataSnapshot]
            {
                array.append(item.value as! Int)

            }
            self.play_array = array
            DispatchQueue.main.async(execute: {
                
                if self.count == 0
                {
                    self.myTableview.reloadData()
                    self.count = self.count + 1
                }
                
            })
            print(self.play_array)
        })
    }
    

    func updateSongsPlays(song: String)
    {

        Database.database().reference().child("Songs").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                
                let newSong = song.replacingOccurrences(of: ".", with: "")
                print(newSong)
                let number  = dictionary[newSong] as? Int
                print(newSong,"play count is: ",number!)
                let currentToBeUpdated = [newSong: number! + 1]
                let songRef = reference?.child("Songs")
                
                songRef?.updateChildValues(currentToBeUpdated, withCompletionBlock: { (err, reference) in
                    if err != nil
                    {
                        print(err!)
                        return
                    }
                    else
                    {
                        print("song successfully updated")
                    }
                })
            }

        }, withCancel: nil)

    }
    func updateUserSelectedSongs()
    {
        if userSongs.contains(currentSong) == false
        {
            userSongs.append(currentSong)
        }
        
        let mySong = ["song": userSongs]
        let userRef = reference?.child("users").child((Auth.auth().currentUser?.uid)!).child("My Songs")
        userRef?.updateChildValues(mySong, withCompletionBlock: { (err, reference) in
            if err != nil
            {
                print(err!)
                return
            }
            else
            {
                print("song saved successfully")
            }
        })
    }
    func createHideButton() -> UIButton {
        let hideButton: UIButton = UIButton(frame: CGRect(x: 0, y: 50, width: self.view.frame.size.width/4, height: 80))
        hideButton.backgroundColor = UIColor.blue
        hideButton.setTitle("hide", for: .normal)
        hideButton.addTarget(self, action: #selector(hideAction(_:)), for: .touchUpInside)
        return hideButton
    }
    func createTabBarFrame() -> UITabBar {
        let tabBar = UITabBar(frame: CGRect(x: 0, y: (self.view.frame.size.height), width: self.view.frame.size.width, height: 100))
        return tabBar
    }
    
    func createPauseButton() -> UIButton {
        pauseButton = UIButton(frame: CGRect(x: (self.view.frame.size.width)/2, y: (self.view.frame.size.height) - 100, width: 50, height: 80))
        pauseButton.backgroundColor = UIColor.blue
        pauseButton.setTitle("pause", for: .normal)
        pauseButton.addTarget(self, action: #selector(pausePlayAction), for: .touchUpInside)
        return pauseButton
    }
    func createBackButton() -> UIButton {
        let backButton: UIButton = UIButton(frame: CGRect(x: ((self.view.frame.size.width)/2) - 80, y: (self.view.frame.size.height) - 100, width: 50, height: 80))
        backButton.backgroundColor = UIColor.blue
        backButton.setTitle("back", for: .normal)
        backButton.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return backButton
    }
    
    func createForwardButton() -> UIButton {
        let forwardButton: UIButton = UIButton(frame: CGRect(x: ((self.view.frame.size.width)/2) + 80, y: (self.view.frame.size.height) - 100, width: 50, height: 20))
        forwardButton.backgroundColor = UIColor.blue
        forwardButton.setTitle("forward", for: .normal)
        forwardButton.addTarget(self, action: #selector(forwardAction(_:)), for: .touchUpInside)
        return forwardButton
    }
    
    func createSlider() -> UISlider {
        playerSlider = UISlider(frame: CGRect(x: 10, y: (self.view.frame.size.height) - 230, width: self.view.frame.size.width - 10, height: 80))
        let audioSession = AVAudioSession.sharedInstance()
        let volume: Int = Int(audioSession.outputVolume)
        playerSlider.isContinuous = true
        playerSlider.setValue(Float(volume), animated: false)
        playerSlider.minimumValue = 0
        playerSlider.maximumValue = 10
        playerSlider.addTarget(self, action: #selector(controlVolume(_:)), for: .valueChanged)
        
        return playerSlider
    }
    func createFrameBackground(image: UIImage) -> UIImageView{
        backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        backgroundImage.image = image
        
        return backgroundImage
    }
    

    @objc func handleLogout()
    {
        do
        {
            try Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
    }
    @objc func controlVolume(_ sender: UISlider)
    {
        AudioPlayer.volume = sender.value
    }

    @objc func songEnded(note: Notification)
    {
        updateSongsPlays(song: currentSong)
        let cell  = myTableview.cellForRow(at: myTableview.indexPathForSelectedRow!) as! AvailableTableViewCell
        cell.num_plays.text = String(Int(cell.num_plays.text!)! + 1)
        
        let startingItem: String = (((AudioPlayer.currentItem?.asset) as? AVURLAsset)?.url.absoluteString)!.replacingOccurrences(of: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/", with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: ".mp3", with: "")
        
        let path: String = (((AudioPlayer.currentItem?.asset) as? AVURLAsset)?.url.absoluteString)!.replacingOccurrences(of: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/", with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: ".mp3", with: "")
        var count = 0
        
        if(list.contains(path))
        {
            while (list[count] != path)
            {
                count = count + 1
            }
            print(count)
            print(list.count)
            if(count == list.count - 1)
            {
                print("last song in queue")
                currentSong = startingItem
                SongLabel.text = startingItem
                print(currentSong)
                currentSong = startingItem.replacingOccurrences(of: " ", with: "%20")
                let currentSongUrl = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+currentSong+".mp3")
                
                let Item = AVPlayerItem(url: currentSongUrl!)
                AudioPlayer = AVPlayer(playerItem:Item)
                AudioPlayer.pause()
                
                playControl = paused
                pauseButton.setTitle("play", for: .normal)
                
            }
            else
            {
                if (songsPlayed < list.count)
                {
                    print("on to the next item")
                    currentSong = list[count + 1]
                    SongLabel.text = currentSong
                    print(currentSong)
                    
                    currentSong = list[count + 1].replacingOccurrences(of: " ", with: "%20")
                    let currentSongUrl = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+currentSong+".mp3")
                    
                    let Item = AVPlayerItem(url: currentSongUrl!)
                    AudioPlayer = AVPlayer(playerItem:Item)
                    if pauseButton.currentTitle == "play"
                    {
                        AudioPlayer.play()
                        playControl = playing
                        pauseButton.setTitle("pause", for: .normal)
                        
                    }
                    else
                    {
                        AudioPlayer.pause()
                        playControl = paused
                        pauseButton.setTitle("play", for: .normal)
                    }

                    NotificationCenter.default.addObserver(self, selector: #selector(songEnded(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: AudioPlayer.currentItem)

                }
                
            }
            
        }

    }

    @objc func hideAction(_ sender: UIButton!) {
        let tc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(tc!, animated: false, completion: nil)
    }

    @objc func pausePlayAction(_ sender: UIButton!) {
        
        if(sender.currentImage?.isEqual(UIImage(named: "pause")))!
        {
            AudioPlayer.pause()
            playControl = paused
            sender.setImage(UIImage(named: "play"), for: .normal)
        }
        else
        {
            AudioPlayer.play()
            playControl = playing
            sender.setImage(UIImage(named: "pause"), for: .normal)
                
        }
        
    }
    
    @objc func backAction(_ sender: UIButton!) {
        
        let path: String = (((AudioPlayer.currentItem?.asset) as? AVURLAsset)?.url.absoluteString)!.replacingOccurrences(of: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/", with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: ".mp3", with: "")
        var count = 0
        
        if(list.contains(path))
        {
            while (list[count] != path)
            {
                count = count + 1
            }
            if(count == 0)
            {
                currentSong = list[count]
                SongLabel.text = currentSong
                print(currentSong)
                currentSong = list[count].replacingOccurrences(of: " ", with: "%20")
                let currentSongUrl = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+currentSong+".mp3")
                
                let Item = AVPlayerItem(url: currentSongUrl!)
                AudioPlayer = AVPlayer(playerItem:Item)
                AudioPlayer.play()
                
                playControl = playing
                pauseButton.setTitle("pause", for: .normal)

            }
            else
            {
                currentSong = list[count-1]
                SongLabel.text = currentSong
                print(currentSong)

                currentSong = list[count-1].replacingOccurrences(of: " ", with: "%20")
                let currentSongUrl = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+currentSong+".mp3")
                
                let Item = AVPlayerItem(url: currentSongUrl!)
                AudioPlayer = AVPlayer(playerItem:Item)
                if pauseButton.currentTitle == "play"
                {
                    AudioPlayer.play()
                    playControl = playing
                    pauseButton.setTitle("pause", for: .normal)
                    
                }
                else
                {
                    AudioPlayer.pause()
                    playControl = paused
                    pauseButton.setTitle("play", for: .normal)
                }

            }
            
        }
        
    }

    @objc func forwardAction(_ sender: UIButton!) {
        songsPlayed = songsPlayed + 1
        let path: String = (((AudioPlayer.currentItem?.asset) as? AVURLAsset)?.url.absoluteString)!.replacingOccurrences(of: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/", with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: ".mp3", with: "")
        var count = 0
        
        if(list.contains(path))
        {
            while (list[count] != path)
            {
                count = count + 1
            }
            print(count)
            print(list.count)
            if(count == list.count - 1)
            {
                print("last in the queue")
                currentSong = list[count]
                SongLabel.text = currentSong
                print(currentSong)
                currentSong = list[count].replacingOccurrences(of: " ", with: "%20")
                let currentSongUrl = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+currentSong+".mp3")
                
                let Item = AVPlayerItem(url: currentSongUrl!)
                toolBarPauseButton.setTitle("play", for: .normal)
                AudioPlayer = AVPlayer(playerItem:Item)
                AudioPlayer.pause()
                playControl = paused
                if toolBarPauseButton.currentTitle == "pause"
                {
                   toolBarPauseButton.setTitle("play", for: .normal)
                }
                
            }
            else
            {
                currentSong = list[count + 1]
                SongLabel.text = currentSong
                print(currentSong)
                print("in the elae")
                currentSong = list[count + 1].replacingOccurrences(of: " ", with: "%20")
                let currentSongUrl = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+currentSong+".mp3")
                    
                let Item = AVPlayerItem(url: currentSongUrl!)
                AudioPlayer = AVPlayer(playerItem:Item)
                if toolBarPauseButton.currentTitle == "play"
                {
                    AudioPlayer.pause()
                    playControl = paused
                    toolBarPauseButton.setTitle("play", for: .normal)
                    
                }
                else if toolBarPauseButton.currentTitle == "pause"
                {
                    AudioPlayer.play()
                    playControl = playing
                    toolBarPauseButton.setTitle("pause", for: .normal)
                }
            }
            
        }
        
        
    }
    
}
