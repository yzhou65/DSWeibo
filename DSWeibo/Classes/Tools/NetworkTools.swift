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
    
    /**
     发送微博
     
     :param: text               需要发送的正文
     :param: image              需要发送的图片
     :param: successCallback    成功后的回调
     :param: errorCallback      失败后的回调
     */
    func sendStatus(text: String, image: UIImage?, successCallback:(status: Status)->(), errorCallback:(error: NSError)->()) {
        var path = "2/statuses/"
        let params = ["access_token": UserAccount.loadAccount()!.access_token!, "status": text]
        if image != nil {
            //发送图片微博
            path += "upload.json"
            POST(path, parameters: params, constructingBodyWithBlock: { (formData) in
                //将数据转换为二进制
                let data = UIImagePNGRepresentation(image!)!
                
                /*
                 data：需要上传的二进制数据
                 name：服务端对应哪个字段名称
                 fileName：文件名称（在大部分服务器上可以随便写）
                 mineType：数据类型
                 */
                formData.appendPartWithFileData(data, name: "pic", fileName: "abc.png", mimeType: "application/octet-stream")
                }, success: { (_, JSON) in
                    successCallback(status: Status(dict: JSON as! [String: AnyObject]))
                }, failure: { (_, error) in
                    errorCallback(error: error)
            })
        }
        else {
            //发送文字微博
            path += "update.json"
            POST(path, parameters: params, success: { (_, JSON) in
                successCallback(status: Status(dict: JSON as! [String: AnyObject]))
                
            }) { (_, error) in
                errorCallback(error: error)
            }
            
        }

    }
    
}
