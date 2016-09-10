//
//  NetworkTools.swift
//  DSWeibo
//
//  Created by Yue on 9/9/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkTools: AFHTTPSessionManager {

    static let tools:NetworkTools = {
        //注意：baseURL一定要以／结尾
//        let t = NetworkTools()
        let url = NSURL(string: "https://api.weibo.com/")
        let t = NetworkTools(baseURL: url)
        
        //设置AFN能够接受的数据类型
        t.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json", "text/json", "text/javascript", "text/plain") as! Set<String>
        return t
    }()
    
    /**
     获取单粒的方法
     */
    class func sharedNetworkTools() -> NetworkTools {
        return tools
    }
    
}
