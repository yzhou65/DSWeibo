//
//  HomeTableViewController.swift
//  DSWeibo
//
//  Created by Yue on 9/6/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

class HomeTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //如果没有登录，就要设置未登录界面信息
        if !userLogin {
            visitorView?.setupVisitorInfo(true, imageName: "visitordiscover_feed_image_house", message: "关注一些人，会这里看看有什么惊喜")
            return
        }
        
        //初始化导航条
        setupNav()
    }
    
    private func setupNav() {
        /*
        //左边按钮
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "navigationbar_friendattention"), forState: UIControlState.Normal)
        leftBtn.setImage(UIImage(named: "navigationbar_friendattention_highlighted"), forState: UIControlState.Highlighted)
        leftBtn.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        //右边按钮
        let rightBtn = UIButton()
        rightBtn.setImage(UIImage(named: "navigationbar_pop"), forState: UIControlState.Normal)
        rightBtn.setImage(UIImage(named: "navigationbar_pop_highlighted"), forState: UIControlState.Highlighted)
        rightBtn.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        */
        
        //封装的设置左右按钮的方法
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("navigationbar_friendattention", target: self, action: #selector(leftItemClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem.createBarButtonItem("navigationbar_pop", target: self, action: #selector(rightItemClick))
        
        //初始化标题按钮
        let titleBtn = TitleButton()
        titleBtn.setTitle("即刻江南", forState: UIControlState.Normal)
        
        titleBtn.addTarget(self, action: #selector(titleBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.titleView = titleBtn
    }
    
    func titleBtnClick(btn: TitleButton) {
        btn.selected = !btn.selected
    }
    
    func leftItemClick(){
        print(#function)
    }
    
    func rightItemClick(){
        print(#function)
    }
    
    
    /* 以下方法应该封装入UIBarButtonItem的category，因为添加barButtonItem和当前控制器无直接关系，并且以后可能在其他地方用得上
    private func createBarButtonItem(imageName:String, target:AnyObject?, action:Selector) -> UIBarButtonItem {
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        btn.sizeToFit()
        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        
        return UIBarButtonItem(customView: btn)
    }*/
}
