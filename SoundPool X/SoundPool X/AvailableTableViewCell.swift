
//
//  AvailableTableViewCell.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/9/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit

class AvailableTableViewCell: UITableViewCell {

    @IBOutlet weak var SongImageView: UIImageView!
    
    @IBOutlet weak var SongTitle: UILabel!
    
    @IBOutlet weak var options_button: UIView!
    
    @IBOutlet weak var Song_Length: UILabel!
    
    @IBOutlet weak var more_button: UIButton!
    @IBOutlet weak var num_plays: UILabel!
    
    @IBOutlet weak var plays_label: UILabel!
    
    let settinglauncher = SettingsLauncher()
    @IBAction func more_action(_ sender: Any) {
        settinglauncher.showSettings((Any).self)
    }
    
    override func awakeFromNib() {
        raise_view(new_view: SongImageView)
        raise_view(new_view: more_button)
    }

    
    func raise_view(new_view: UIView){
        new_view.layer.borderWidth = 1
        new_view.layer.borderColor = UIColor.black.cgColor
        new_view.layer.cornerRadius = new_view.frame.width/12.0
    }

    
}
