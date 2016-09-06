//
//  MainViewController.swift
//  DSWeibo
//
//  Created by Yue on 9/6/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

/**
 command + j -> 定位到目录文杰
 ⬆️⬇️键选择文件夹
 按回车 -> command＋c 拷贝文件名称
 command ＋ n：创建文件
 */
class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置当前控制器对应tabBar的颜色
        //注意：在ios7以前如果设置了tintColor只有文字会变，而图片不会变
        tabBar.tintColor = UIColor.orangeColor()
        
        addChildViewController("HomeTableViewController", title: "首页", imageName: "tabbar_home")
        addChildViewController("MessageTableViewController", title: "消息", imageName: "tabbar_message_center")
        addChildViewController("DiscoverTableViewController", title: "发现", imageName: "tabbar_discover")
        addChildViewController("ProfileTableViewController", title: "我", imageName: "tabbar_profile")
        
    }
    
    /**
     初始化子控制器。需要传入子控制器对象，标题和图片
     */
    private func addChildViewController(childControllerName: String, title:String, imageName:String) {
        
        // <DSWeibo.HomeTableViewController: 0x7ff3a15967c0>
//        print(childController)
        
        //动态获取命名空间
        let ns = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] as! String   //将CFBundleExecutable的value取出来赋给一个String变量
        
        //将字符串转换为类（要注意类的命名空间）
        //默认情况下，命名空间就是项目名称，但是命名空间可以被修改，所以要动态获取命名空间
        let cls:AnyClass? = NSClassFromString(ns + "." + childControllerName)
        
        //通过类创建对象. 要将AnyClass转换为UIViewController的类型
        let vcCls = cls as! UIViewController.Type
        let vc = vcCls.init()
        
        //设置首页tabbar对应的数据
        vc.tabBarItem.image = UIImage(named: imageName)
        vc.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")
        vc.title = title
        
        //给首页包装一个导航控制器
        let nav = UINavigationController()
        nav.addChildViewController(vc)
        
        //将导航控制器添加到当前控制器
        addChildViewController(nav)
        
        
    }
}
