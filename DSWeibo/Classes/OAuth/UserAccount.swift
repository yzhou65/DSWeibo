//
//  UserAccount.swift
//  DSWeibo
//
//  Created by Yue on 9/9/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit
import SVProgressHUD

// Swift2.0打印对象需要重写CustomStringConvertable协议中的description
class UserAccount: NSObject, NSCoding {

    ///用于调用access_token，接口获取授权后的accessToken
    var access_token: String?
    ///access_token的生命周期，单位是秒数
    var expires_in: NSNumber?{
        didSet{ //给expires_in属性赋值后就会调用
            expires_date = NSDate(timeIntervalSinceNow: expires_in!.doubleValue)
        }
    }
    ///保存用户过期时间
    var expires_date: NSDate?
    ///当前授权用户的UID
    var uid: String?
    ///用户大头像地址, 180*180 pixels
    var avatar_large: String?
    ///用户昵称
    var screen_name: String?
    
    static var account: UserAccount?
    
    override init(){}
    
    init(dict: [String: AnyObject]){
        /* 注意：如果不用kvc而是直接在初始化的时候赋值，则不会调用上面的didSet方法
        access_token = dict["access_token"] as? String
        expires_in = dict["expires_in"] as? NSNumber
        uid = dict["uid"] as? String
        */
        super.init()
        setValuesForKeysWithDictionary(dict) //kvc
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        print(key)
    }
    
    override var description: String {
        //定义属性数组
        let properties = ["access_token", "expires_in", "uid", "expires_date", "avatar_large", "screen_name"]
        //根据属性数组，将属性转换为字典
        let dict = self.dictionaryWithValuesForKeys(properties)
        //将字典转换为字符串
        return "\(dict)"
    }
    
    func loadUserInfo(completed:(account: UserAccount?, error:NSError?)->()) {
        //断言
        assert(access_token != nil, "没有授权")
        
        let path = "2/users/show.json"
        let params = ["access_token":access_token!, "uid":uid!]
        
        NetworkTools.sharedNetworkTools().GET(path, parameters: params, success: { (_, JSON) in
            
            //判断字典是否有值
            if let dict = JSON as? [String: AnyObject] {
                self.screen_name = dict["screen_name"] as? String
                self.avatar_large = dict["avatar_large"] as? String
                //通知外面，user info加载完了
                completed(account: self, error: nil)
                return
            }
            
            completed(account: nil, error: nil)
            
            }) { (_, error) in
                print(error)
                completed(account: nil, error: error)
        }
    }
    
    /**
     返回用户是否已经登录
     */
    class func isUserLogin() -> Bool {
        return UserAccount.loadAccount() != nil
    }
    
    //MARK: － 保存和读取授权模型
    static let filePath = "account.plist".cacheDir()
    /**
     保存授权模型
     */
    func saveAccount() {
        NSKeyedArchiver.archiveRootObject(self, toFile: UserAccount.filePath) //对象方法中如果要访问静态变量必须要用类名.的形式
    }
    
    /**
     加载授权模型
     */
    class func loadAccount() -> UserAccount? {
        //判断是否已经加载过
        if account != nil {
            return account
        }
        account = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? UserAccount
        
        //判断授权信息是否过期
        if account?.expires_date?.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            return nil  //已经过期
        }
        
        return account
    }
    
    //MARK: -NSCoding
    /**
     将对象写入到文件
     */
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(access_token, forKey: "access_token")
        aCoder.encodeObject(expires_in, forKey: "expires_in")
        aCoder.encodeObject(uid, forKey: "uid")
        aCoder.encodeObject(expires_date, forKey: "expires_date")
        aCoder.encodeObject(screen_name, forKey: "screen_name")
        aCoder.encodeObject(avatar_large, forKey: "avatar_large")
    }
    
    /**
     从文件中读取对象
     */
    required init?(coder aDecoder: NSCoder) {
        access_token = aDecoder.decodeObjectForKey("access_token") as? String
        expires_in = aDecoder.decodeObjectForKey("expires_in") as? NSNumber
        uid = aDecoder.decodeObjectForKey("uid") as? String
        expires_date = aDecoder.decodeObjectForKey("expires_date") as? NSDate
        screen_name = aDecoder.decodeObjectForKey("screen_name") as? String
        avatar_large = aDecoder.decodeObjectForKey("avatar_large") as? String
    }
}
