//
//  UITextView+Category.swift
//  表情键盘界面布局
//
//  Created by Yue on 9/16/16.
//  Copyright © 2016 小码哥. All rights reserved.
//

import UIKit

extension UITextView {
    func insertEmoticon(emoticon: Emoticon) {
        //处理删除按钮
        if emoticon.isRemoveButton {
            deleteBackward() 
        }
        
        //判断当前点击的是否是emoji表情
        if emoticon.emojiStr != nil {
            //以下代码有可能因为循环引用导致无法调用deinit。解决办法就是在闭包arg前加上[unowned self]修饰
            self.replaceRange(self.selectedTextRange!, withText: emoticon.emojiStr!)
        }
        
        //判断当前点击的是否是表情图片
        if emoticon.png != nil {
            
            //创建表情字符串
            let imageText = EmoticonTextAttachment.imageText(emoticon, font: font ?? UIFont.systemFontOfSize(17)) //直接使用TextView的font
            
            //拿到当前所有的内容
            let strM = NSMutableAttributedString(attributedString: self.attributedText)
            
            //插入表情到当前光标所在的位置
            let range = self.selectedRange //用户选中的Range
            strM.replaceCharactersInRange(range, withAttributedString: imageText)
            //属性字符串有自己默认的尺寸
            strM.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(range.location, 1))
            
            //将替换后的字符串赋值给UITextView
            self.attributedText = strM
            
            //回复光标所在的位置
            //两个参数：第一个是指定光标所在的位置，第二个参数是选中文本的个数
            self.selectedRange = NSMakeRange(range.location + 1, 0)
            
            //注意：如果先输入的是默认表情（非emoji），不会触发textViewDidChange的监听方法，所以需要自己主动调用
            //自己主动出发textViewDidChange方法
            delegate?.textViewDidChange!(self)
        }
    }
    
    /**
     获取需要发送给服务器的字符串
     */
    func emoticonAttributedText() -> String {
        //需要发送给服务器的数据
        var strM = String()
        attributedText.enumerateAttributesInRange(NSMakeRange(0, attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (objc, range, _) in
            /*
             //遍历的时候传递给我们的objc是一个字典。如果字典中的NSAttachment这个key有值，那么就证明当前是一个图片
             print(objc["NSAttachment"])
             // range就是纯字符串的范围
             // 如果纯字符串中间有图片表情，那么range就会传递多次
             print(range)
             let res = (self.customTextView.text as NSString).substringWithRange(range)
             print(res)
             print("+++++++++++++++++++")
             */
            
            // range就是纯字符串的范围
            // 如果纯字符串中间有图片表情，那么range就会传递多次
            if objc["NSAttachment"] != nil {
                let attachment = objc["NSAttachment"] as! EmoticonTextAttachment
                strM += attachment.chs!
            }
            else {
                //文字
                strM += (self.text as NSString).substringWithRange(range)
            }
        }
        return strM
    }
}


