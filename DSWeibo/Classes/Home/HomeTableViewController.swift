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
        
        //注册通知，监听菜单的弹出与关闭
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(change), name: YZPopoverAnimatorWillShow, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(change), name: YZPopoverAnimatorWillDismiss, object: nil)
    }
    
    deinit {
        //移除通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     监听菜单的弹出与关闭，修改标题按钮的状态
     */
    func change() {
        //修改标题按钮的状态
        let titleBtn = navigationItem.titleView as! TitleButton
        titleBtn.selected = !titleBtn.selected
    }
    
    /**
     初始化导航条
     */
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
    
    /**
     监听首页导航条中间按钮的点击
     */
    func titleBtnClick(btn: TitleButton) {
        //修改箭头方向
//        btn.selected = !btn.selected //通知方法中改过了，此处不需要再改
        
        //弹出菜单
        let sb = UIStoryboard(name: "PopoverViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        
        //设置专场代理和转场
        //默认情况下，modal会移除以前控制器的view，替换为当前弹出的view
        //如果自定义转场，那么就不会移除以前控制器的view
//        vc?.transitioningDelegate = self
        
        //用自己作为转场动画代理不合适，改用一个PopoverAnimator对象来管理
        vc?.transitioningDelegate = popoverAnimator
        vc?.modalPresentationStyle = UIModalPresentationStyle.Custom //这里用自定义转场样式，而不是Popover，这样就不会移除以前的控制器view，而是直接盖上面modal
        presentViewController(vc!, animated: true, completion: nil)
    }
    
    func leftItemClick(){
        print(#function)
    }
    
    /**
     监听首页导航条右边的按钮
     */
    func rightItemClick(){
//        print(#function)
        
        let sb = UIStoryboard(name: "QRCodeViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        presentViewController(vc!, animated: true
            , completion: nil)
    }
    
    //MARK: - 懒加载［
    /**
     一定要定义一个属性来保存自定义转场对象，否则会报错
     */
    private lazy var popoverAnimator: PopoverAnimator = {
        let pa = PopoverAnimator()
        pa.presentFrame = CGRect(x: 100, y: 56, width: 200, height: 350)
        return pa
    }()
    
}
