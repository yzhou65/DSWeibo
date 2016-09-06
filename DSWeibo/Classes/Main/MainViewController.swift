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
        
        addChildViewController(HomeTableViewController(), title: "首页", imageName: "tabbar_home")
        addChildViewController(MessageTableViewController(), title: "消息", imageName: "tabbar_message_center")
        addChildViewController(DiscoverTableViewController(), title: "发现", imageName: "tabbar_discover")
        addChildViewController(ProfileTableViewController(), title: "我", imageName: "tabbar_profile")
        
    }
    
    /**
     初始化子控制器。需要传入子控制器对象，标题和图片
     */
    private func addChildViewController(childController: UIViewController, title:String, imageName:String) {
        //设置首页tabbar对应的数据
        childController.tabBarItem.image = UIImage(named: imageName)
        childController.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")
        
        //设置导航条对应的数据
        childController.title = title
        
        //给首页包装一个导航控制器
        let nav = UINavigationController()
        nav.addChildViewController(childController)
        
        //将导航控制器添加到当前控制器
        addChildViewController(nav)
    }
}
