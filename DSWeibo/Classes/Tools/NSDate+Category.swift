//
//  NSDate+Category.swift
//  DSWeibo
//
//  Created by Yue on 9/11/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

extension NSDate {
    class func dateWithString(time: String) -> NSDate {
        //将服务器返回的时间字符串转换为NSDate
        //创建formatter
        let formatter = NSDateFormatter()
        //设置时间格式
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z yyyy"
        //设置时间的区域（真机必须设置，否则可能不能转换成功）
        formatter.locale = NSLocale(localeIdentifier: "en")
        //转换字符串，转换好的时间是取出时区的时间
        let createdDate = formatter.dateFromString(time)!
        
        return createdDate
    }
    
    var descDate: String {
        /*
         刚刚（一分钟内）
         X分钟前（1小时内）
         X小时前（当天）
         昨天 HH：mm
         MM－dd HH：mm（一年内）
         yyyy－MM－dd HH：mm（更早期）
         */
        let calendar = NSCalendar.currentCalendar()
        //判断是否是今天
        if calendar.isDateInToday(self) {
            //获取当前时间和系统时间之前的差距（秒数）
            let since = Int(NSDate().timeIntervalSinceDate(self))
//            print("since = \(since)")
            //判断是否是刚刚
            if since < 60 {
                return "刚刚"
            }
            //多少分钟以前
            if since < 60 * 60 {
                return "\(since/60)分钟前"
            }
            //多少小时以前
            return "\(since/(60 * 60))小时前"
        }
        
        //判断是否是昨天
        var formatterStr = "HH:mm"
        if calendar.isDateInYesterday(self) {
            formatterStr = "昨天: " + formatterStr
        } else {
            //处理一年以内
            formatterStr = "MM-dd " + formatterStr
            //处理更早时间
            let comps = calendar.components(NSCalendarUnit.Year, fromDate: self, toDate: NSDate(), options: NSCalendarOptions(rawValue:0))
            if comps.year >= 1 {
                formatterStr = "yyyy-" + formatterStr
            }
        }
        //按照指定的格式将时间转换为字符串
        let formatter = NSDateFormatter()
        //设置时间格式
        formatter.dateFormat = formatterStr
        //设置时间的区域（真机必须设置，否则可能不能转换成功）
        formatter.locale = NSLocale(localeIdentifier: "en")
        //格式化
        
        return formatter.stringFromDate(self)
    }
}
