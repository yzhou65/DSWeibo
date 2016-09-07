//
//  VisitorView.swift
//  DSWeibo
//
//  Created by Yue on 9/6/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

// Swift中如何定义协议
protocol VisitorViewDelegate: NSObjectProtocol {
    //点击登录按钮的回调
    func loginBtnWillClick()
    
    //点击注册按钮的回调
    func registerBtnWillClick()
}

class VisitorView: UIView {
    //定义一个属性保存代理对象. 一定要加weak来避免循环引用
    weak var delegate: VisitorViewDelegate?
    
    /**
     设置未登录界面
     
     :param: isHome     是否是首页
     :param: imageName  需要展示的图标名称
     :param: message    需要展示的文本内容
     */
    func setupVisitorInfo(isHome:Bool, imageName:String, message:String) {
        //如果不是首页，就隐藏转盘背景
        iconView.hidden = !isHome
        
        //修改中间图标
        homeIcon.image = UIImage(named: imageName)
        
        //修改文本
        messageLabel.text = message
        
        //判断是否需要执行动画
        if isHome {
            startAnimation()
        }
    }
    
    //MARK: 按钮监听
    func loginBtnClick() {
//        print(#function)
        delegate?.loginBtnWillClick()
    }
    
    func registerBtnClick() {
//        print(#function)
        
        //OC中调用代理要先判断是否respondToSelector，而Swift中直接用delegate?
        delegate?.registerBtnWillClick()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //添加子控件
        addSubview(iconView)
        addSubview(maskBGView)
        addSubview(homeIcon)
        addSubview(messageLabel)
        addSubview(loginButton)
        addSubview(registerButton)
        
        //布局子控件
        //布局背景
        iconView.xmg_AlignInner(type: XMG_AlignType.Center, referView: self, size: nil)
        
        //布局小房子图标
        homeIcon.xmg_AlignInner(type: XMG_AlignType.Center, referView: self, size: nil)
        
        //布局文本
        messageLabel.xmg_AlignVertical(type: XMG_AlignType.BottomCenter, referView: iconView, size: nil)
        
        //给文本设置约束。公式：“哪个控件”的“什么属性” “等于” “另一个控件”的“什么属性” ＊ “多少” ＋ “constant”
        let widthCons = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 224)
        addConstraint(widthCons)
        
        //布局按钮
        registerButton.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: messageLabel, size: CGSize(width: 100, height: 30), offset: CGPoint(x: 0, y: 20))
        loginButton.xmg_AlignVertical(type: XMG_AlignType.BottomRight, referView: messageLabel, size: CGSize(width: 100, height: 30), offset: CGPoint(x: 0, y: 20))
        
        //布局蒙版
        maskBGView.xmg_Fill(self)
    }
    
    /**
     Swift推荐：当自定义一个控件时，要么用纯代码，要么就用xib／storyboard
     */
    required init?(coder aDecoder: NSCoder) {
        //如果通过xib／storyboard创建该类，那么就会崩溃
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 内部控制方法
    private func startAnimation(){
        //创建动画
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        //设置动画属性
        anim.toValue = 2 * M_PI
        anim.duration = 20
        anim.repeatCount = MAXFLOAT
        
        //改属性默认为true，代表动画只要执行完毕就移除，那么下次再进来同一个界面就不会再有动画。所以要避免这个问题，就要设置为false
        anim.removedOnCompletion = false
        
        //将动画添加到图层
        iconView.layer.addAnimation(anim, forKey: nil)
    }
    
    //MARK: 懒加载控件
    ///转盘形背景
    private lazy var iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
        return iv
    }()
    
    ///图标
    private lazy var homeIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
        return iv
    }()
    
    ///文本
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "adfslfj"
        label.numberOfLines = 0
        label.textColor = UIColor.darkGrayColor()
        return label
    }()
    
    ///登录按钮
    private lazy var loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        btn.setTitle("登录", forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named:"common_button_white_disable"), forState: UIControlState.Normal)
        
        btn.addTarget(self, action: #selector(loginBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    ///注册按钮
    private lazy var registerButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        btn.setTitle("注册", forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named:"common_button_white_disable"), forState: UIControlState.Normal)
        
        btn.addTarget(self, action: #selector(registerBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    private lazy var maskBGView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
        return iv
    }()

}
