//
//  NewfeatureCollectionViewController.swift
//  DSWeibo
//
//  Created by Yue on 9/10/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class NewfeatureCollectionViewController: UICollectionViewController {

    //布局对象
    private var layout: NewfeatureLayout = NewfeatureLayout()
    //页面个数
    private let pageCount = 4
    
    //系统置顶的初始化方法是带参数的，所以这里不用写override
    init(){
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //此处的UICollectionViewCell.self就相当于OC中的[UICollectionViewCell class]
        self.collectionView!.registerClass(NewfeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        /*
         layout的具体设置应该交给layout自己，而不是放在外面
        //设置layout
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        //设置collectionView属性
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.pagingEnabled = true
        */
    }
    

    // MARK: - UICollectionViewDataSource
    /**
     返回多少个cell
     */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount
    }

    /**
     返回对应indexPath的cell数据
     */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NewfeatureCell
        //设置cell数据
        cell.imageIndex = indexPath.item
    
        return cell
    }
    
    /**
     完全显示好一个cell后调用
     */
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //传递的indexPath是上一页的index
        
        //拿到当前显示的cell对应的索引
        let path = collectionView.indexPathsForVisibleItems().last!
        
        //拿到当前索引对应的cell
        if path.item == pageCount - 1 {
            let cell = collectionView.cellForItemAtIndexPath(path) as! NewfeatureCell
            //让cell执行按钮动画
            cell.startBtnAnimation()
        }
    }

}

/**
 自定义cell
 */
private class NewfeatureCell: UICollectionViewCell {
    
    //MARK: - 懒加载
    private lazy var iconView = UIImageView()
    private lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named:"new_feature_button"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named:"new_feature_button_highlighted"), forState: UIControlState.Highlighted)
        btn.hidden = true
        btn.addTarget(self, action: #selector(startBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    /**
     “进入微博”的按钮的监听回调
     */
    @objc func startBtnClick() {
//        print(#function)
        //去主页。注意：企业开发中，如果要切换根控制器，最好都在AppDelegate中进行
        NSNotificationCenter.defaultCenter().postNotificationName(YZSwitchRootViewControllerKey, object: true)
    }
    
    //MARK: - 设置iconView
    ///保存图片index.
    //被private修饰的东西，如果在同一个文件也可以访问
    private var imageIndex: Int? {
        //imageIndex设置了值以后，可以动态拼接iconView的图片名称
        didSet{
            iconView.image = UIImage(named: "new_feature_\(imageIndex!+1)")
        }
    }
    
    /**
     让按钮做动画
     */
    func startBtnAnimation() {
        startBtn.hidden = false
        
        //执行动画
        startBtn.transform = CGAffineTransformMakeScale(0.0, 0.0)
        startBtn.userInteractionEnabled = false
        
        //rawValue:0 就是OC的kNilOptions
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 8, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.startBtn.transform = CGAffineTransformIdentity
            }, completion: { (_) in
                self.startBtn.userInteractionEnabled = true
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //初始化UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        //添加子控件到contentView上
        contentView.addSubview(iconView)
        contentView.addSubview(startBtn)
        
        //布局子控件位置
        iconView.xmg_Fill(contentView)
        startBtn.xmg_AlignInner(type: XMG_AlignType.BottomCenter, referView: contentView, size: nil, offset: CGPoint(x: 0, y: -160)) //参照contentView的底部向上－160
    }
}

/**
 自定义layout
 */
private class NewfeatureLayout: UICollectionViewFlowLayout {
    
    /**
     准备布局。先调用numberOfItemsInSection方法，然后prepareLayout，最后调用cellForItemAtIndexPath
     */
    override func prepareLayout() {
        itemSize = UIScreen.mainScreen().bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        //设置collectionView属性
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.pagingEnabled = true
    }
}
