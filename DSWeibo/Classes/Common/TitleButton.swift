//
//  TitleButton.swift
//  DSWeibo
//
//  Created by Yue on 9/7/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

/**
 首页界面导航条中间的带箭头按钮
 */
class TitleButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        setImage(UIImage(named: "navigationbar_arrow_down"), forState: UIControlState.Normal)
        setImage(UIImage(named: "navigationbar_arrow_up"), forState: UIControlState.Selected)
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        /* 此方法会被调用2次，所以偏移会移太多
        titleLabel?.frame.offsetInPlace(dx: -imageView!.bounds.width, dy: 0)
        imageView?.frame.offsetInPlace(dx: titleLabel!.bounds.width, dy: 0)
        */
        
        //与OC不同的是，Swift允许直接修改结构体的成员变量
        titleLabel?.frame.origin.x = 0
        imageView?.frame.origin.x = titleLabel!.frame.size.width + 5
    }

}
