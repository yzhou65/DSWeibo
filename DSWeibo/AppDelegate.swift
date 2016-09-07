//
//  AppDelegate.swift
//  DSWeibo
//
//  Created by Yue on 9/6/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //设置导航条和工具条的外观。字都变成橙色
        //外观一旦设置全局有效，所以应该在程序进入的时候就设置，以后就不用再在各控制器设置
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        UITabBar.appearance().tintColor = UIColor.orangeColor()
        
        //创建window和根控制器
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = MainViewController() //调用后，主控制器的viewDidLoad就会调用
        window?.makeKeyAndVisible() //调用后，主控制器的viewWillAppear才会调用
        
        
        return true
    }

}

