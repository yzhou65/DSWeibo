//
//  AppDelegate.swift
//  DSWeibo
//
//  Created by Yue on 9/6/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

///切换控制器通知
let YZSwitchRootViewControllerKey = "YZSwitchRootViewControllerKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //注册一个通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(switchRootViewController), name: YZSwitchRootViewControllerKey, object: nil)
        
        //设置导航条和工具条的外观。字都变成橙色
        //外观一旦设置全局有效，所以应该在程序进入的时候就设置，以后就不用再在各控制器设置
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        UITabBar.appearance().tintColor = UIColor.orangeColor()
        
        //创建window和根控制器
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        
        window?.rootViewController = defaultController() //调用后，主控制器的viewDidLoad就会调用
        window?.makeKeyAndVisible() //调用后，主控制器的viewWillAppear才会调用
        
        //判断是否有新版本
        print(isNewVersion())
        
        return true
    }
    
    
    func switchRootViewController(note: NSNotification) {
        if note.object as! Bool {
            window?.rootViewController = MainViewController()
        } else {
            window?.rootViewController = WelcomeViewController()
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     用于获取默认界面。返回默认界面
     */
    func defaultController() -> UIViewController {
        //判断用户是否已经登录
        if UserAccount.isUserLogin() {
            //判断是否有新版本
            return isNewVersion() ? NewfeatureCollectionViewController() : WelcomeViewController()
        }
        return MainViewController()
    }
    
    private func isNewVersion() -> Bool {
        //获取当前软件的版本号 －> info.plist
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        
        //获取以前的软件版本号 -> 从本地文件中读取（以前自己存储的）
        //最后的?? ""的意思是，如果前面的string是nil就取值为""
        let sandboxVersion = NSUserDefaults.standardUserDefaults().objectForKey("CFBundleShortVersionString") as? String ?? ""
        
        print("current = \(currentVersion) sandbox = \(sandboxVersion)")
        
        //比较两个版本号
        //如果当前>以前，有新版本。存储当前最新版本号
        if currentVersion.compare(sandboxVersion) == NSComparisonResult.OrderedDescending {
            //ios7以后，就不用再调用synchronize方法了，可以直接存
            NSUserDefaults.standardUserDefaults().setObject(currentVersion, forKey: "CFBundleShortVersionString")
            return true
        }
        
        //否则，没有新版本
        return false
    }

}

