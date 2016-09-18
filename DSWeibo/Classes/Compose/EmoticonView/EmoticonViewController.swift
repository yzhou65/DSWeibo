//
//  EmoticonViewController.swift
//  表情键盘界面布局
//
//  Created by xiaomage on 15/9/16.
//  Copyright © 2015年 小码哥. All rights reserved.
//
/*
 结构：
 1. 加载emoticons.plist拿到魅族表情的路径
 emoticons.plist(存储了所有表情的数据的字典)
 |----packages(字典数组)
         |----id(存储了对应组表情对应的文件夹)
 
 2. 根据拿到的路径加载对应组表情的info.plist
 info.plist（字典）
 |----id(当前组表情文件夹的名称)
 |----group_name_cn(组的名称)
 |----emoticons(字典数组，里面存储了所有表情)
         |----chs（表情对应的文字）
         |----png(表情对应的图片）
            |----code(emoji表情对应的十六进制字符串）
 
 */

import UIKit

private let YZEmotionCellID = "YZEmotionCellID"
class EmoticonViewController: UIViewController {
    
    /// 定义一个闭包属性，用于传递选中的表情模型
    var emoticonDidSelectCallBack:(emoticon: Emoticon)->()
    
    init(callBack: (emoticon: Emoticon)->()) {
        self.emoticonDidSelectCallBack = callBack
        super.init(nibName: nil, bundle: nil)  //写闭包就必须调用这个super的方法
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.redColor()
        
        // 1.初始化UI
        setupUI()
        
//        print(EmoticonPackage.loadPackages())
    }
    /**
    初始化UI
    */
    private func setupUI()
    {
        // 1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        
        // 2.布局子控件
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        // 提示: 如果想自己封装一个框架, 最好不要依赖其它框架
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionView": collectionView, "toolbar": toolbar]
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolbar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-[toolbar(44)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        
        view.addConstraints(cons)
    }
    
    /**
     点击默认就滚动到默认，点击emoji就滚动到emoji。。。
     */
    func itemClick(item: UIBarButtonItem)
    {
        /**
         传入一个indexPath就滚动到相应indexPath
         */
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: item.tag), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
    
    // MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: EmotionLayout())
        //注册cell
        clv.registerClass(EmoticonCell.self, forCellWithReuseIdentifier: YZEmotionCellID)
        clv.dataSource = self
        clv.delegate = self
        return clv
    }()
    
    private lazy var toolbar: UIToolbar = {
       let bar = UIToolbar()
        bar.tintColor = UIColor.darkGrayColor()
        var items = [UIBarButtonItem]()
        
        var index = 0
        for title in ["最近", "默认", "emoji", "浪小花"]
        {
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(itemClick(_:)))
            item.tag = index++
            items.append(item)
            //为了让4个按钮等分toolbar，所以在它们中间添加“弹簧”
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        //去掉最后一个“弹簧”
        items.removeLast()
        bar.items = items
        return bar
    }()
    
    private lazy var packages: [EmoticonPackage] = EmoticonPackage.packageList
}


extension EmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    //MARK: - UICollectionViewDataSource
    /**
     多少组
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    /**
     每组多少个
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons?.count ?? 0
    }
    
    /**
     每行显示的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(YZEmotionCellID, forIndexPath: indexPath) as! EmoticonCell
        cell.backgroundColor = UIColor.redColor()
        cell.backgroundColor = (indexPath.item % 2 == 0) ? UIColor.redColor() : UIColor.greenColor()
        
        //取出对应的组
        let package = packages[indexPath.section]
        //取出对应组对应行的模型
        let emoticon = package.emoticons![indexPath.item]
        cell.emoticon = emoticon
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    /**
     选中某个item 时调用
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //将当前使用的表情添加到“最近”的数组中
        let emoticon = packages[indexPath.section].emoticons![indexPath.item]
        emoticon.times++
        packages[0].appendRecentEmoticons(emoticon)
        collectionView.reloadSections(NSIndexSet(index: 0))
        
        //回调通知使用者当前点击了哪个表情
        emoticonDidSelectCallBack(emoticon: emoticon)
    }
}

class EmoticonCell: UICollectionViewCell {
    
    var emoticon : Emoticon? {
        didSet{
            //判断是否是图片表情
            if emoticon!.chs != nil {
                iconButton.setImage(UIImage(contentsOfFile:(emoticon!.imagePath)!), forState: UIControlState.Normal)
            }
            else {
                //防止重用
                iconButton.setImage(nil, forState: UIControlState.Normal)
            }
            
            //设置emoji表情
            //注意：加上??可以防止重用
            iconButton.setTitle(emoticon!.emojiStr ?? "", forState: UIControlState.Normal)
            
            //判断是否是删除按钮
            if emoticon!.isRemoveButton {
                iconButton.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
                iconButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /**
     初始化UI
     */
    private func setupUI() {
        contentView.addSubview(iconButton)
//        iconButton.frame = contentView.bounds
        iconButton.backgroundColor = UIColor.whiteColor()
        iconButton.frame = CGRectInset(contentView.bounds, 4, 4)
        iconButton.userInteractionEnabled = false
    }
    
    //MARK: - cell懒加载
    private lazy var iconButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFontOfSize(32)
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 自定义布局
class EmotionLayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        let width = collectionView!.bounds.width / 7
        itemSize = CGSize(width: width, height: width)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        //设置collectionView相关属性
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        //注意：最好不用乘以0.5，因为CGFloat不准确，所以如果乘以0.5在iphone4会有问题
        let y = (collectionView!.bounds.height - 3 * width) * 0.48
        collectionView?.contentInset = UIEdgeInsets(top: y
            , left: 0, bottom: y, right: 0)
    }
}
