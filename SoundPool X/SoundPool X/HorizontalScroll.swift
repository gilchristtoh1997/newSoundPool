//
//  HorizontalScroll.swift
//  SoundPool X
//
//  Created by Gilchrist Toh on 8/23/17.
//  Copyright © 2017 Gilchrist Toh. All rights reserved.
//

import UIKit
@objc protocol HorizontalScrollerDelegaate
{
    func numberofScrollViewElements() -> Int
    
    func elementAtScrollViewIndex(index: Int) -> UIView
}
class HorizontalScroll: UIView {
    var delegate: HorizontalScrollerDelegaate?
    var scroller: UIScrollView!
    let padding: Int = 10
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpScroll()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToSuperview() {
        reload()
    }
    func setUpScroll()
    {
        scroller = UIScrollView()
        self.addSubview(scroller)
        
        /**scroller.translatesAutoresizingMaskIntoConstraints = true
        let dict = ["scroller": scroller]
        let constraint1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scroller]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict as Any as! [String : Any])
        
        let constraint2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scroller]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict as Any as! [String : Any])
        
        self.addConstraints(constraint2)
        self.addConstraints(constraint1)**/
        
    }
    func reload()
    {
        if let del = delegate
        {
            var xOffset: CGFloat = 0
            for index in 0..<del.numberofScrollViewElements(){
                let view = del.elementAtScrollViewIndex(index: index)
                view.frame = CGRect(x: Int(xOffset), y: 0, width: 100, height: 100)
                xOffset = xOffset + CGFloat(padding) + view.frame.size.width
                scroller.addSubview(view)
            }
            
            scroller.contentSize = CGSize(width: xOffset, height: self.frame.height)
        }
    }
}
