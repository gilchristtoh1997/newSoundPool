//
//  searchCell.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 9/10/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit

class searchCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func getSongTitle(name:String)
    {
        title.text = name
    }
    
}
