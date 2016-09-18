//
//  UIBarButtonItem+Category.swift
//  DSWeibo
//
//  Created by Yue on 9/7/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    //如果再func前面加上class，就相当于OC中的 ＋ ，即类方法
    class func createBarButtonItem(imageName:String, target:AnyObject?, action:Selector) -> UIBarButtonItem {
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        btn.sizeToFit()
        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        
        return UIBarButtonItem(customView: btn)
    }
    
    convenience init(imageName:String, target:AnyObject?, action:Selector){
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        
        //如果是自己封装一个按钮，最好传入字符串，然后再将字符串包装为Selector
        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        btn.sizeToFit()
        self.init(customView:btn)
    }
    
}


