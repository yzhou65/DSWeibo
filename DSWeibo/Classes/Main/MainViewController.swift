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
//        tabBar.tintColor = UIColor.orangeColor()
    
        // 添加子控制器
        addChildControllers()
        
        //从ios7开始就不推荐大家在viewDidLoad中设置frame，而应在viewWillAppear设置
//        print(tabBar.subviews)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        print("-----------------")
//        print(tabBar.subviews)
        
        //添加＋号按钮
        setupComposeBtn()
    }
    
    /**
     监听＋号按钮的点击
     注意：此方法不能是private，否则会崩溃。因为这个方法不是在当前类中触发的，而是runtime中CFRunLoop监听且以消息机制传递的，所以不能设置为private
     */
    func composeBtnClick(){
        print(#function)
    }
    
    //MARK: 内部控制方法
    
    /**
     添加＋号按钮
     */
    private func setupComposeBtn() {
        tabBar.addSubview(composeBtn)
        
        //调整＋号按钮的位置
        let width = UIScreen.mainScreen().bounds.size.width / CGFloat(viewControllers!.count)
        
        let rect = CGRect(x: 2 * width, y: 0, width: width, height: 49)
        composeBtn.frame = rect
    }
    
    /**
     添加所有子控制器
     */
    private func addChildControllers() {
        //获取json文件的路径
        let path = NSBundle.mainBundle().pathForResource("MainVCSettings.json", ofType: nil)
        
        //通过文件路径创建NSData
        if let jsonPath = path {
            let jsonData = NSData(contentsOfFile: jsonPath)
            
            do {
                //有可能发生异常的代码放到这里
                //序列化json数据－>Array
                //try：发生异常会跳到catch中继续执行
                //try!：发生异常程序直接就崩溃
                let dictArr = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers)
                
                //遍历数组，动态创建控制器和设置数据
                //Swift中，如果需要遍历一个数组，必须先明确数据类型
                for dict in dictArr as! [[String: String]]
                {
                    //报错的原因：addChildViewController方法的参数必须有值，但是字典的返回值是可选类型，所以全部要加上返回值
                    addChildViewController(dict["vcName"]!, title: dict["title"]!, imageName: dict["imageName"]!)
                }
            } catch {
                //发生异常之后会执行的
                print(error)
                
                //从本地创建控制器
                addChildViewController("HomeTableViewController", title: "首页", imageName: "tabbar_home")
                addChildViewController("MessageTableViewController", title: "消息", imageName: "tabbar_message_center")
                
                //添加一个占位控制器（为中间的＋号）
                addChildViewController("NullViewController", title: "", imageName: "")
                
                addChildViewController("DiscoverTableViewController", title: "发现", imageName: "tabbar_discover")
                addChildViewController("ProfileTableViewController", title: "我", imageName: "tabbar_profile")
            }
            
        }

    }
    
    /**
     初始化子控制器。需要传入子控制器对象，标题和图片
     */
    private func addChildViewController(childControllerName: String, title:String, imageName:String) {
        
        // <DSWeibo.HomeTableViewController: 0x7ff3a15967c0>
        
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
    
    //MARK: 懒加载
    private lazy var composeBtn: UIButton = {
        let btn = UIButton()
        //设置前景背景图片
        btn.setImage(UIImage(named:"tabbar_compose_icon_add"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named:"tabbar_compose_icon_add_highlighted"), forState: UIControlState.Highlighted)
        btn.setBackgroundImage(UIImage(named:"tabbar_compose_button"), forState: UIControlState.Normal)
    btn.setBackgroundImage(UIImage(named:"tabbar_compose_button_highlighted"), forState: UIControlState.Highlighted)
        
        //添加监听
        btn.addTarget(self, action: #selector(composeBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
}
