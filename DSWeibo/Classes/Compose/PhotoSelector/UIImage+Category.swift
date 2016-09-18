//
//  UIImage+Category.swift
//  图片选择器
//
//  Created by Yue on 9/17/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     根据传入的宽度生成一张图片
     按照图片的宽高比来scale图片
     
     param: 指定宽度
     */
    func imageScaledWithWidth(width: CGFloat) -> UIImage {
        //根据宽度计算高度
        let height = size.height / size.width * width
        //按照宽高比绘制一张新的图片
        let currentSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(currentSize)
        drawInRect(CGRect(origin: CGPointZero, size: currentSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
