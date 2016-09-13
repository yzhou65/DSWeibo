//
//  UILabel+Category.swift
//  DSWeibo
//
//  Created by Yue on 9/11/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

extension UILabel {
    
    /**
     快速创建一个UILabel
     */
    class func createLabel(color:UIColor, fontSize: CGFloat) -> UILabel{
        let label = UILabel()
        label.textColor = color
        label.font = UIFont.systemFontOfSize(fontSize)
        return label
    }
}
