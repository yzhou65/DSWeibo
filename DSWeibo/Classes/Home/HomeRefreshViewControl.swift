//
//  HomeRefreshViewControl.swift
//  DSWeibo
//
//  Created by Yue on 9/12/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

class HomeRefreshViewControl: UIRefreshControl {

    override init() {
        super.init()
        
        //初始化UI
        setupUI()
    }
    
    private func setupUI() {
        //添加子控件
        addSubview(refreshView)
        
        //布局子控件
        refreshView.xmg_AlignInner(type: XMG_AlignType.Center, referView: self, size: CGSize(width: 170, height: 60))
        
        /*
         1. 当用户下拉到一定程度，需要旋转箭头
         2. 当用户上推到一定程度，也需要旋转箭头
         3. 当下拉刷新控件出发刷新方法时，需要显示刷新界面（转轮）
         
         可以用kvo监听frame的改变
         越往下拉，y值越小
         越往上推，y值越大
        */
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    /// 定义变量记录是否需要旋转监听
    private var rotationArrowFlag = false
    /// 定义变量记录当前是否正在执行转圈动画
    private var loadingViewAnimFlag = false
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        print(frame.origin.y)
        
        //过滤不需要的frame数据
        if frame.origin.y >= 0 {
            return
        }
        
        //判断是否已经出发刷新事件
        if refreshing && !loadingViewAnimFlag{
            //显示圈圈，并执行旋转动画
            loadingViewAnimFlag = true
            refreshView.startLoadingViewAnim()
            return
        }
        
        if frame.origin.y >= -50 && rotationArrowFlag{
            print("翻转回来")
            rotationArrowFlag = false
            refreshView.rotationArrowIcon(rotationArrowFlag)
        } else if frame.origin.y < -50 && !rotationArrowFlag {
            print("翻转")
            rotationArrowFlag = true
            refreshView.rotationArrowIcon(rotationArrowFlag)
        }
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        
        //关闭圈圈动画
        refreshView.stopLoadingViewAnim()
        
        //复位圈圈动画标记
        loadingViewAnimFlag = false
    }
    
    deinit{
        removeObserver(self, forKeyPath: "frame")
    }
    
    //MARK: - 懒加载
    private lazy var refreshView: HomeRefreshView = HomeRefreshView.refreshView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeRefreshView: UIView {
    
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var loadingView: UIImageView!
    
    /**
     旋转箭头
     */
    func rotationArrowIcon(flag: Bool) {
        var angle = M_PI
        angle += flag ? -0.01 : 0.01
        UIView.animateWithDuration(0.2) { 
            self.arrowIcon.transform = CGAffineTransformRotate(self.arrowIcon.transform, CGFloat(angle))
        }
    }
    
    func startLoadingViewAnim() {
        tipView.hidden = true
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.duration = 1
        anim.repeatCount = MAXFLOAT
        
        anim.removedOnCompletion = false
        loadingView.layer.addAnimation(anim, forKey: nil)
    }
    
    func stopLoadingViewAnim() {
        tipView.hidden = false
        loadingView.layer.removeAllAnimations()
    }
    
    class func refreshView() -> HomeRefreshView {
        return NSBundle.mainBundle().loadNibNamed("HomeRefreshView", owner: nil, options: nil).last as! HomeRefreshView
    }
}
