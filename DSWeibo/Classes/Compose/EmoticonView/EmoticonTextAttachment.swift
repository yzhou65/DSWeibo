//
//  EmoticonTextAttachment.swift
//  表情键盘界面布局
//
//  Created by Yue on 9/16/16.
//  Copyright © 2016 小码哥. All rights reserved.
//

import UIKit

class EmoticonTextAttachment: NSTextAttachment {

    /// 保存对应表情的文字
    var chs: String?
    
    /**
     根据表情模型，创建表情字符串
     */
    class func imageText(emoticon: Emoticon, font: UIFont) -> NSAttributedString {
        //创建图片属性字符串
        let attachment = EmoticonTextAttachment()
        attachment.chs = emoticon.chs
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        let s = font.lineHeight
        attachment.bounds = CGRectMake(0, -4, s, s)
        
        //根据附件创建属性字符串
        return NSAttributedString(attachment: attachment)
    }
    
}
