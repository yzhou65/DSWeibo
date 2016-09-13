//
//  Status.swift
//  DSWeibo
//
//  Created by xiaomage on 15/9/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

import UIKit
import SDWebImage

class Status: NSObject {
    /// 微博创建时间
    var created_at: String? {
        didSet{
            //将字符串转换为时间
//            created_at = "Fri Sep 9 14:50:57 +0800 2016" // For debugging
            
            let createdDate = NSDate.dateWithString(created_at!)
            
            created_at = createdDate.descDate
        }
    }
    /// 微博ID
    var id: Int = 0
    /// 微博信息内容
    var text: String?
    /// 微博来源
    var source: String? {
        didSet{
            // <a href=\"http://app.weibo.com/t/feed/4fuyNj\" rel=\"nofollow\">barney</a>
            //截取字符串
            if let str = source {
                if str == "" {
                    return
                }
                let startLocation = (str as NSString).rangeOfString(">").location + 1
                let length = (str as NSString).rangeOfString("<", options: NSStringCompareOptions.BackwardsSearch).location - startLocation
                source = "来自：" + (str as NSString).substringWithRange(NSMakeRange(startLocation, length))
            }
        }
    }
    /// 配图数组
    var pic_urls: [[String: AnyObject]]? {
        didSet {
            //初始化数组
            storedPicURLS = [NSURL]()
            //遍历取出所有的图片路径字符串
            for dict in pic_urls! {
                if let urlStr = dict["thumbnail_pic"] {
                    //将字符串专为URL保存到数组
                    storedPicURLS?.append(NSURL(string: urlStr as! String)!)
                }
            }
        }
    }
    /// 保存当前微博所有配图的URL
    var storedPicURLS: [NSURL]?
    /// 用户信息
    var user: User?
    /// 转发微博
    var retweeted_status: Status?
    
    // 如果有转发，原创就没有配图
    /// 定义一个计算属性，用于返回原创或者转发配图的URL数组
    var pictureURLS: [NSURL]? {
        return retweeted_status != nil ? retweeted_status?.storedPicURLS : storedPicURLS
    }
    
    /// 加载微博数据
    class func loadStatuses(since_id: Int, completed: (models:[Status]?, error:NSError?)->()){
        let path = "2/statuses/home_timeline.json"
        var params = ["access_token": UserAccount.loadAccount()!.access_token!]
        
        //下拉刷新
        if since_id > 0 {
            params["since_id"] = "\(since_id)"
        }
        
        NetworkTools.sharedNetworkTools().GET(path, parameters: params, success: { (_, JSON) -> Void in
//            print(JSON)
            // 1.取出statuses key对应的数组 (存储的都是字典)
            // 2.遍历数组, 将字典转换为模型
            let models = dictToModel(JSON!["statuses"] as! [[String: AnyObject]])
            
            //缓存微博配图
            cacheStatusImages(models, completed: completed)

            // 2.通过闭包将数据传递给调用者
//            finished(models: models, error: nil)
            
            }) { (_, error) -> Void in
                print(error)
                completed(models: nil, error: error)
        }
    }
    
    class func cacheStatusImages(list: [Status], completed: (models:[Status]?, error:NSError?)->()) {
        
        if list.count == 0 {
            completed(models: list, error: nil)
            return
        }
        
        //创建一个线程组. 要保证下载完所有图片后，才能通知外界
        let group = dispatch_group_create()
        
        //缓存图片
        for status in list {
            //判断当前微博石头有配图，如果没有就直接跳过. 可以使用Swift新语法guard
//            if status.storedPicURLS == nil {
//                continue
//            }
            //Swift2.0新语法，如果条件为nil，就执行else后面的语句
            guard let _ = status.pictureURLS else
            {
                continue
            }
            
            for url in status.pictureURLS! {
                //将党啊钱的下载操作添加到组
                dispatch_group_enter(group)
                
                //开启子线程，缓存图片
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue:0), progress: nil, completed: { (_, _, _, _, _) in
                    //离开当前组
                    dispatch_group_leave(group)
//                    print("cache done")
                })
            }
        }
        
        //当所有图片下载完毕后，再通过闭包通知调用者
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            //如果能够来到这里，一定是所有图片都下载完毕
            print("over")
            completed(models: list, error: nil)
        }
    }
    
    /// 将字典数组转换为模型数组
    class func dictToModel(list: [[String: AnyObject]]) -> [Status] {
        var models = [Status]()
        for dict in list
        {
            models.append(Status(dict: dict))
        }
        return models
    }
    
    // 字典转模型的构造方法
    init(dict: [String: AnyObject])
    {
        super.init()
        setValuesForKeysWithDictionary(dict) //字典里的属性必须和模型属性一一对应，但是字典里有很多模型中没有的属性，所以要写一个setValue(forUndefinedKey)方法
    }
    
    /**
     setValuesForKeysWithDictionary内部会调用此方法
     */
    override func setValue(value: AnyObject?, forKey key: String) {
//        print("key = \(key), value = \(value)")
        
        //判断当前是否正在给微博字典中的user字典赋值
        if "user" == key {
            //根据user key对应的字典创建模型
            user = User(dict: value as! [String: AnyObject])
            return 
        }
        
        //判断是否时转发微博，如果是，就自己处理
        if "retweeted_status" == key {
            retweeted_status = Status(dict: value as! [String: AnyObject])
            return
        }
        super.setValue(value, forKey: key)
    }
    
    /**
     解决字典中有很多模型没有的属性的问题
     */
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    // 打印当前模型
    var properties = ["created_at", "id", "text", "source", "pic_urls"]
    //相当于java的toString方法
    override var description: String {
        let dict = dictionaryWithValuesForKeys(properties)
        return "\(dict)"
    }
}
