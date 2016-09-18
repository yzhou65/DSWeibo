//
//  ComposeViewController.swift  编写微博的controller
//  DSWeibo
//
//  Created by Yue on 9/14/16.
//  Copyright © 2016 fda. All rights reserved.
//


import UIKit
import SVProgressHUD

class ComposeViewController: UIViewController {
    //MARK: - 重要懒加载
    /// 表情键盘
    private lazy var emoticonVC: EmoticonViewController = EmoticonViewController { [unowned self](emoticon) in
        //TODO: 还不能动态获取
        self.textView.insertEmoticon(emoticon)
    }
    /// 图片选择器
    private lazy var photoSelectorVC: PhotoSelectorViewController = PhotoSelectorViewController()
    
    /// 工具条底部的约束
    var toolbarButtonCons: NSLayoutConstraint?
    /// 图片选择器高度约束
    var photoViewHeightCon: NSLayoutConstraint?

    //MARK: - 主要方法
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        //注册通知监听键盘的弹出和消失
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardChange), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        // 1.将键盘控制器添加为当前控制器的子控制器，并将emoticonVC的表情键盘传递给textView的键盘
        addChildViewController(emoticonVC)
        addChildViewController(photoSelectorVC)
        
        //初始化导航条
        setupNav()
        //初始化输入框
        setupInputView()
        //初始化图片选择器
        setupPhotoView()
        //初始化工具条
        setupToolbar()
    }
    
    /**
     只要键盘改变状态就会调用
     */
    func keyboardChange(note: NSNotification) {
//        print(note)
        //取出键盘最终的rect
        let rect = (note.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        //修改工具条的底部约束
        //弹出： Y ＝ 409 height ＝ 258
        //关闭： Y ＝ 667 height ＝ 258
        let height = UIScreen.mainScreen().bounds.height
        toolbarButtonCons?.constant = -(height - rect.origin.y)
        //更新界面
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        
        /* 
         工具条回弹是因为执行了两次动画，而系统自带的动画节奏（曲线）是7
         7 在apple API中并没有提供给我们，但是我们可以使用
         7 这种节奏有个特点：如果连续执行两次动画，不管上一次有没有执行完毕，都会立刻执行下一次也，就是说上一次可能会被忽略
         如果动画节奏设置为7，那么动画的时长无论如何都会自动修改为0.5
         UIView动画的本质是核心动画，所以可以给核心动画设置动画节奏.
         以下代码要先获得动画节奏
        */
        let curve = note.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        UIView.animateWithDuration(duration.doubleValue) {
            //设置动画节奏
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve.integerValue)!)
            self.view.layoutIfNeeded()
        }
        
        let anim = toolbar.layer.animationForKey("position")
        print("duration = \(anim?.duration)")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     在此方法中实现键盘自动弹出
     */
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //为了避免选择照片的时候键盘再次弹出
        if photoViewHeightCon?.constant == 0 {
            //主动召唤键盘
            textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //主动隐藏键盘
        textView.resignFirstResponder()
    }
    
    private func setupToolbar() {
        view.addSubview(toolbar)
        view.addSubview(wordCounter)
        
        //添加按钮
        var items = [UIBarButtonItem]()
        let itemSettings = [["imageName": "compose_toolbar_picture", "action": "selectPicture"], ["imageName": "compose_mentionbutton_background"], ["imageName": "compose_trendbutton_background"], ["imageName": "compose_emoticonbutton_background", "action":"inputEmoticon"], ["imageName": "compose_addbutton_background"]]
        for dict in itemSettings {
            let action = dict["action"]
            var item = UIBarButtonItem()
            if action != nil {
                item = UIBarButtonItem(imageName: dict["imageName"]!, target: self, action: Selector(action!))
            } else {
                item = UIBarButtonItem(imageName: dict["imageName"]!, target: self, action: nil)
            }
            items.append(item)
            //最后一个item之后不需要“弹簧”
            if dict == itemSettings.last! {
                break
            }
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
//        items.removeLast()
        toolbar.items = items
        
        //布局toolbar
        let width = UIScreen.mainScreen().bounds.width
        let constraint = toolbar.xmg_AlignInner(type: XMG_AlignType.BottomLeft, referView: view, size: CGSize(width: width, height: 44))
        toolbarButtonCons = toolbar.xmg_Constraint(constraint, attribute: NSLayoutAttribute.Bottom)
        
        
        wordCounter.xmg_AlignVertical(type: XMG_AlignType.TopRight, referView: toolbar, size: nil, offset: CGPoint(x: -10, y: -10))
    }
    
    /**
     选择相片
     */
    func selectPicture() {
        //关闭键盘
        textView.resignFirstResponder()
        
        //调整图片选择器的高度
        photoViewHeightCon?.constant = UIScreen.mainScreen().bounds.height * 0.6
    }
    
    /**
     设置选择相片的view
     */
    func setupPhotoView() {
        // 添加图片选择器
        view.insertSubview(photoSelectorVC.view, belowSubview: toolbar)
        // 布局
        let size = UIScreen.mainScreen().bounds.size
        let width = size.width
        let height: CGFloat = 0 //size.height * 0.6
        let cons = photoSelectorVC.view.xmg_AlignInner(type: XMG_AlignType.BottomLeft, referView: view, size: CGSize(width: width, height: height))
        photoViewHeightCon = photoSelectorVC.view.xmg_Constraint(cons, attribute: NSLayoutAttribute.Height)
    }
    
    /**
     切换表情键盘
     */
    func inputEmoticon(){
        //结论：如果inputView是系统自带的键盘，那么就是nil
        //如果不是系统自带的键盘，那么inputView就有值
//        print(textView.inputView)
        
        //关闭键盘
        textView.resignFirstResponder()
        //设置inputView
        textView.inputView = (textView.inputView == nil) ? emoticonVC.view : nil
        //重新召唤出键盘
        textView.becomeFirstResponder()
    }
    
    /**
     初始化输入视图
     */
    private func setupInputView() {
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag  //拖拽的时候键盘消失
        
        //布局
        textView.xmg_Fill(view)
        placeholderLabel.xmg_AlignInner(type: XMG_AlignType.TopLeft, referView: textView, size: nil, offset: CGPoint(x: 5, y: 8))
    }
    
    /**
     初始化导航条
     */
    private func setupNav() {
        //添加左右按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(closeView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain
            , target: self, action: #selector(sendStatus))
        navigationItem.rightBarButtonItem?.enabled = false
        
        //添加中间视图
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        let label1 = UILabel()
        label1.text = "发送微博"
        label1.font = UIFont.systemFontOfSize(15)
        label1.sizeToFit()
        titleView.addSubview(label1)
        
        let label2 = UILabel()
        label2.text = UserAccount.loadAccount()?.screen_name
        label2.font = UIFont.systemFontOfSize(13)
        label2.textColor = UIColor.darkGrayColor()
        label2.sizeToFit()
        titleView.addSubview(label2)
        
        //布局
        label1.xmg_AlignInner(type: XMG_AlignType.TopCenter, referView: titleView, size: nil)
        label2.xmg_AlignInner(type: XMG_AlignType.BottomCenter, referView: titleView, size: nil)
        
        navigationItem.titleView = titleView
        
    }
    
    func closeView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     "发送"按钮的监听
     */
    func sendStatus() {
        let text = textView.emoticonAttributedText()
        let image = photoSelectorVC.photoImages.first
        
        NetworkTools.sharedNetworkTools().sendStatus(text, image: image, successCallback: { (status) in
            //提示用户发送成功
            SVProgressHUD.showSuccessWithStatus("发送成功")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            
            //关闭编辑界面
            self.closeView()
            
            }) { (error) in
                //提示用户发送失败
                print(error)
                SVProgressHUD.showErrorWithStatus("发送失败")
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        }
        
    }
    
    //MARK: - 懒加载
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFontOfSize(20)
        tv.delegate = self
        return tv
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(20)
        label.textColor = UIColor.darkGrayColor()
        label.text = "分享新鲜事..."
        return label
    }()
    
    private lazy var toolbar: UIToolbar = UIToolbar()
    
    private lazy var wordCounter: UILabel = {
        let label = UILabel()
        
        return label
    }()
}

//MARK: - UITextViewDelegate
/// 一条微博字数限制
private let maxWordCount = 10
extension ComposeViewController: UITextViewDelegate {
    /**
     注意：输入默认图片表情的时候不会触发本方法
     */
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.hasText()
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
        
        ///当前已经输入的内容的长度
        let count = textView.emoticonAttributedText().characters.count
        ///还能继续输入的内容长度
        let remain = maxWordCount - count
        wordCounter.textColor = (remain > 0) ? UIColor.darkGrayColor() : UIColor.redColor()
        wordCounter.text = remain == maxWordCount ? "" : "\(remain)"
    }
}