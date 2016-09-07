//
//  ProfileTableViewController.swift
//  DSWeibo
//
//  Created by Yue on 9/6/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

class ProfileTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //如果没有登录，就要设置未登录界面信息
        if !userLogin {
            visitorView?.setupVisitorInfo(false, imageName: "visitordiscover_image_profile", message: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人")
        }
        
    }
}
