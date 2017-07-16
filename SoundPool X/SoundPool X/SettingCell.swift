//
//  SettingCell.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 6/28/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit

class SettingCell: BaseCell {
    
    override var isHighlighted: Bool
    {
        didSet
        {
            
            if isHighlighted == true
            {
                backgroundColor = UIColor.darkGray
                the_label.textColor = UIColor.white
                iconImageView.tintColor = UIColor.white
            }
            else
            {
                backgroundColor = UIColor.white
                the_label.textColor = UIColor.black
                iconImageView.tintColor = UIColor.darkGray
            }
            

        }
    }
    
    var setting: Setting? {
        didSet{
            backgroundColor = UIColor.white
            the_label.text = setting?.name
            the_label.font = UIFont.systemFont(ofSize: 12)
            if let imageName = setting?.imageName{
                iconImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = UIColor.darkGray
            }
        }
    }
    
    let the_label: UILabel = {
        let label = UILabel()
        label.text = "Setting"
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_circles_black_16")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    override func setupViews() {
        super.setupViews()
        addSubview(the_label)
        addSubview(iconImageView)
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]-8-[v1]|", views: iconImageView, the_label)
        addConstraintsWithFormat(format: "V:|[v0]|", views: the_label)
        addConstraintsWithFormat(format: "V:[v0(30)]", views: iconImageView)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for(index, view) in views.enumerated()
        {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
