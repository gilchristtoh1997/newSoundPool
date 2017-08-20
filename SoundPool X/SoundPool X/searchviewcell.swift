//
//  searchviewcell.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 8/19/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit

class searchviewcell: UITableViewCell {

    @IBOutlet var SongName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func CommonInit(name: String)
    {
        SongName.text = name
    }
    
}
