//
//  BaseCell.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/28/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews()
    {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
