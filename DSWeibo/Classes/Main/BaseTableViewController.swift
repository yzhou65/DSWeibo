//
//  BaseTableViewController.swift
//  DSWeibo
//
//  Created by Yue on 9/6/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController, VisitorViewDelegate {

    //定义一个变量保存用户当前是否登录
    var userLogin = UserAccount.isUserLogin()
    
    //定义属性保存未登录界面
    var visitorView: VisitorView?
    
    override func loadView() {
        
        userLogin ? super.loadView() : setupVisitorView()
    }
    
    //MARK: 内部控制方法
    /**
     创建未登录界面
     */
    private func setupVisitorView() {
        //初始化未登录界面
        let customView = VisitorView()
        customView.delegate = self
        view = customView
        visitorView = customView
        
        //设置未登录时导航条的按钮
//        navigationController?.navigationBar.tintColor = UIColor.orangeColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(registerBtnWillClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(loginBtnWillClick))
    }
    
    //MARK: VisitorViewDelegate代理方法
    func loginBtnWillClick() {
//        print(#function)
        
        //弹出登录界面
        let oauthVC = OAuthViewController()
        let nav = UINavigationController(rootViewController: oauthVC)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    func registerBtnWillClick(){
//        print(NetworkTools.sharedNetworkTools())
//        print(NSDate(timeIntervalSinceNow: 157679999.0))
        
        
    }
}
