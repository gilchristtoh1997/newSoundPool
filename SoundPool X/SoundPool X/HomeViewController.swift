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
import Alamofire
import FirebaseAuth

struct cellData
{
    let cell : Int!
    let text : String!
    let length: String!
    var plays: Int!
    let image : UIImage!
}

public var AudioPlayer =  AVPlayer()
public var SelectedSongNumber = Int()
var playerSlider = UISlider()
var pauseButton = UIButton()
let SongLabel = UILabel()
var currentSong = " "
var playing = 1
var paused = 0
var playControl = 0
var songsPlayed = 0
var reference:DatabaseReference?
var userSongs: [String] = []
var likesArray: [Int] = []

var item_reference : String = ""
let list: [String] = ["Halsey - Colors", "Kygo - It Aint Me", "Martin Garrix & Dua Lipa - Scared To Be Lonely", "Miley Cyrus - Party In The U.S.A.", "The Goodnight - I Will Wait"]

class HomeViewController: UITableViewController, URLSessionTaskDelegate, AVAudioPlayerDelegate {
    
    var arrayOfCellData = [cellData]()
    let cellSpacingHeight: CGFloat = 0
    var currSongPlays: Int = 0
    var cell: AvailableTableViewCell! = nil
    var playCount = 0
    var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser?.uid == nil
        {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        var idx: Int!
        idx = 1
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
            arrayOfCellData.append(cellData(cell: idx, text: list[idx-1],length: formattedDuration, plays: currSongPlays,image: #imageLiteral(resourceName: "BackGroundHand")))
            idx = idx + 1
        }
        
        self.GetUsername(uid: (Auth.auth().currentUser?.uid)!, tableView: self.tableView) { (name) in
            print(name)
            let indexPath = self.tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
            
            let currentCell = self.tableView.cellForRow(at: indexPath!) as! AvailableTableViewCell
            
            for items in name
            {
                currentCell.num_plays.text = String(items)
            }

        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func GetUsername(uid:String , tableView: UITableView, completion: @escaping ([Int]) -> ()) {
        Database.database().reference().child("Songs").observeSingleEvent(of: .value) { (snapshot:DataSnapshot) in
            var array: [Int] = []
            for item in snapshot.children.allObjects as! [DataSnapshot]
            {
                array.append(item.value as! Int)
                
            }
            completion(array)
           
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = Bundle.main.loadNibNamed("AvailableTableViewCell", owner: self, options: nil)?.first as! AvailableTableViewCell
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)

        cell.backgroundColor = UIColor.white
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
            
        cell.SongImageView.image = arrayOfCellData[indexPath.row].image
        cell.SongTitle.text = arrayOfCellData[indexPath.row].text
        cell.Song_Length.text = arrayOfCellData[indexPath.row].length
        cell.num_plays.text = String(arrayOfCellData[indexPath.row].plays)
            
        return cell
            
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! AvailableTableViewCell

        reference = Database.database().reference(fromURL: "https://soundpool-x.firebaseio.com/")
        let tc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        songsPlayed = songsPlayed + 1
        currentSong = arrayOfCellData[(indexPath?.row)!].text
        updateUserSelectedSongs()

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "playing")
        SongLabel.frame = CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: 80)
        SongLabel.textAlignment = NSTextAlignment.center
        SongLabel.text = arrayOfCellData[(indexPath?.row)!].text
        
        vc?.view.addSubview(createTabBarFrame())
        vc?.tabBarItem.image = UIImage(named: "google")
        vc?.tabBarItem.title = "Playing"
        vc?.view.addSubview(createFrameBackground(image: arrayOfCellData[(indexPath?.row)!].image))
        vc?.view.addSubview(SongLabel)
        vc?.view.addSubview(createPauseButton())
        vc?.view.addSubview(createBackButton())
        vc?.view.addSubview(createForwardButton())
        vc?.view.addSubview(createSlider())
        

        tc?.addChildViewController(vc!)
        self.present(tc!, animated: false, completion: nil)
        
        currentCell.num_plays.text = String(arrayOfCellData[(indexPath?.row)!].plays + 1)
        updateSongsPlays(song: currentSong)
        
        print("playing ",currentSong)
        let song = currentSong.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+song+".mp3")
        
        let playerItem = AVPlayerItem(url: url!)
        AudioPlayer = AVPlayer(playerItem:playerItem)
        AudioPlayer.play()

        playControl = playing
        
        NotificationCenter.default.addObserver(self, selector: #selector(songEnded(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: AudioPlayer.currentItem)
        

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
        let forwardButton: UIButton = UIButton(frame: CGRect(x: ((self.view.frame.size.width)/2) + 80, y: (self.view.frame.size.height) - 100, width: 100, height: 80))
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
    

    func handleLogout()
    {
        do
        {
            try Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
    }
    func controlVolume(_ sender: UISlider)
    {
        AudioPlayer.volume = sender.value
    }

    func songEnded(note: Notification)
    {
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
                print("back to beginning item")
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
                    AudioPlayer.play()
                    
                    playControl = playing
                    pauseButton.setTitle("pause", for: .normal)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(songEnded(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: AudioPlayer.currentItem)

                }
                
            }
            
        }
        

    }

    func pausePlayAction(_ sender: UIButton!) {
        
        if(sender.currentTitle == "pause")
        {
            AudioPlayer.pause()
            playControl = paused
            sender.setTitle("play", for: .normal)
        }
        else
        {
            AudioPlayer.play()
            playControl = playing
            sender.setTitle("pause", for: .normal)
                
        }
        
    }
    
    func backAction(_ sender: UIButton!) {
        
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
                AudioPlayer.play()
                
                playControl = playing
                pauseButton.setTitle("pause", for: .normal)

            }
            
        }
        
    }
    func forwardAction(_ sender: UIButton!) {
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
                currentSong = list[count]
                SongLabel.text = currentSong
                print(currentSong)
                currentSong = list[count].replacingOccurrences(of: " ", with: "%20")
                let currentSongUrl = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+currentSong+".mp3")
                
                let Item = AVPlayerItem(url: currentSongUrl!)
                AudioPlayer = AVPlayer(playerItem:Item)
                AudioPlayer.pause()
                
                playControl = paused
                pauseButton.setTitle("play", for: .normal)
                
            }
            else
            {
                currentSong = list[count + 1]
                SongLabel.text = currentSong
                print(currentSong)
                    
                currentSong = list[count + 1].replacingOccurrences(of: " ", with: "%20")
                let currentSongUrl = URL(string: "http://soundpool.cs.loyola.edu/Song_Folder/a_songs/"+currentSong+".mp3")
                    
                let Item = AVPlayerItem(url: currentSongUrl!)
                AudioPlayer = AVPlayer(playerItem:Item)
                AudioPlayer.play()
                    
                playControl = playing
                pauseButton.setTitle("pause", for: .normal)

                
                
            }
            
        }
        
        
    }

    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
    
        return 200

    }
    
    
}
