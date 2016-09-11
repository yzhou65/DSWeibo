//
//  OAuthViewController.swift
//  DSWeibo
//
//  Created by xiaomage on 15/9/10.
//  Copyright © 2015年 小码哥. All rights reserved.
//

import UIKit
import SVProgressHUD

class OAuthViewController: UIViewController {

    let WB_App_Key = "3919080122"
    let WB_App_Secret = "9da1f47e2e837ae8275793fc7658ea46"
    let WB_redirect_uri = "http://www.520it.com"
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 0.初始化导航条
        navigationItem.title = "barney微博"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(close))
        
        // 1.获取未授权的RequestToken
        // 要求SSL1.2
        let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_App_Key)&redirect_uri=\(WB_redirect_uri)"
        let url = NSURL(string: urlStr)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    func close()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - 懒加载
    private lazy var webView: UIWebView = {
        let wv = UIWebView()
        wv.delegate = self
        return wv
    }()
}

extension OAuthViewController: UIWebViewDelegate {
    /**
     拦截请求。如果return true就正常加载，否则就不加载
     */
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.URL?.absoluteString)
        
        /*
        加载授权界面：https://api.weibo.com/oauth2/authorize?client_id=3919080122&redirect_uri=http://www.520it.com
        
        跳转到授权界面：https://api.weibo.com/oauth2/authorize
        如果授权成功：http://www.520it.com/?code=f6a9490502d736c9088b97f12ab9805a
        如果取消授权：http://www.520it.com/?error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330
        */
        
        //判断是否是授权回调页面，如果不是就继续加载
        let urlStr = request.URL!.absoluteString
        if !(urlStr.hasPrefix(WB_redirect_uri)) {
            //继续加载
            return true
        }
        //判断是否授权成功
        let codeStr = "code="
        if request.URL!.query!.hasPrefix(codeStr) { //query是url?后的请求参数
            //授权成功
            print("授权成功")
            //取出已经授权的RequestToken
            let code = request.URL!.query?.substringFromIndex(codeStr.endIndex) //codeStr.endIndex == codeStr最后一位
            //利用已经授权的requestToken换取AccessToken
            loadAccessToken(code!)
        }
        else {
            //取消授权
            print("取消授权")
            //关闭界面
            close()
        }
        return false
    }
    

    func webViewDidStartLoad(webView: UIWebView) {
        //提示用户正在加载
        SVProgressHUD.showInfoWithStatus("loading...")
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        //关闭提示
        SVProgressHUD.dismiss()
    }
    
    /**
     换取AccessToken。Code是已经授权的RequestToken
     */
    private func loadAccessToken(code: String){
        //定义路径
        let path = "oauth2/access_token"
        //封装参数
        let params = ["client_id":WB_App_Key, "client_secret":WB_App_Secret, "grant_type":"authorization_code", "code":code, "redirect_uri":WB_redirect_uri]
        //发post请求
        NetworkTools.sharedNetworkTools().POST(path, parameters: params, success: { (_, JSON) in
            
            /*
            do{
             //验证expires_in不是字符串，而是NSNumber
                let data = try NSJSONSerialization.dataWithJSONObject(JSON!, options: NSJSONWritingOptions.PrettyPrinted)
                let dataStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print(dataStr)
                
            }catch{
                
            }
            */
            
            /*结论：同一个用户对同一个应用程序授权多次access_token是一样的。每个access_token都是有过期时间的：
             1. 如果自己对自己的应用进行授权，有效时间是5年差1天
             2. 如果其他人对你的应用进行授权，有效时间是3天
            */
            
            /*
             plist：只能存储系统自带的数据类型
             将对象转换为json之后写入文件中－－》许多公司已经使用
             归档：可以存储自定义对象
             数据库：用于存储大数据，特点是效率高
            */
            //字典转模型
            let account = UserAccount(dict: JSON as! [String: AnyObject])
//            print(account)
            
            //获取用户信息
            //用闭包的形式在获取了用户信息后，归档用户信息。这样就可以保证异步请求加载完成后，再调用闭包
            account.loadUserInfo{ (account, error) in
                if account != nil {
                    account!.saveAccount()
                    //去欢迎界面
                    NSNotificationCenter.defaultCenter().postNotificationName(YZSwitchRootViewControllerKey, object: false)
                    return
                }
                
                SVProgressHUD.showInfoWithStatus("Failed to load user info", maskType: SVProgressHUDMaskType.Black)
            }
            
            //由于加载用户信息是异步的，所以如果在这里归档可能会因为用户信息还没在子线程中加载完而导致保存空值. 不能在这里归档
//            account.saveAccount()
            
            }) { (_, error) in
                print(error)
        }
    }
}
