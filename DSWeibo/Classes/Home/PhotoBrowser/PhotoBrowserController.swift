//
//  PhotoBrowserController.swift
//  DSWeibo
//
//  Created by Yue on 9/13/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit
import SVProgressHUD

private let photoBrowserCellID = "Cell"

class PhotoBrowserController: UIViewController {
    
    var currentIndex: Int?
    var pictureURLs: [NSURL]?
    init(index: Int, urls: [NSURL]) {
        //Swift与法规定，必须先初始化当前类属性，再初始化父类
        currentIndex = index
        pictureURLs = urls
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor() //这样就不会出现先看见关闭和保存按钮，再看到背景的现象
        
        //初始化UI
        setupUI()
    }
    
    private func setupUI() {
        //添加子控件
        view.addSubview(collectionView)
        view.addSubview(closeBtn)
        view.addSubview(saveBtn)
        
        //布局子控件
        closeBtn.xmg_AlignInner(type: XMG_AlignType.BottomLeft, referView: view, size: CGSize(width: 100, height: 35), offset: CGPoint(x: 10, y: -10))
        saveBtn.xmg_AlignInner(type: XMG_AlignType.BottomRight, referView: view, size: CGSize(width: 100, height: 35), offset: CGPoint(x: -10, y: -10))
        collectionView.frame = UIScreen.mainScreen().bounds
        
        //设置数据源
        collectionView.dataSource = self
        collectionView.registerClass(PhotoBrowserCell.self, forCellWithReuseIdentifier: photoBrowserCellID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     “关闭”按钮的监听
     */
    func closeView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     “保存”按钮的监听
     */
    func save() {
        //拿到当前正在显示的cell
        let index = collectionView.indexPathsForVisibleItems().last!
        let cell = collectionView.cellForItemAtIndexPath(index) as! PhotoBrowserCell
        
        //保存图片
        let image = cell.iconView.image
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(PhotoBrowserController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    }
    
    
    func image(image: UIImage, didFinishSavingWithError error:NSError?, contextInfo:AnyObject) {
        if error != nil {
            SVProgressHUD.showErrorWithStatus("保存失败")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        }
        else {
            SVProgressHUD.showSuccessWithStatus("保存成功")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        }
    }

    //MARK: - 懒加载
    private lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("关闭", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.darkGrayColor()
        
        btn.addTarget(self, action: #selector(closeView), forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    private lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("保存", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.darkGrayColor()
        
        btn.addTarget(self, action: #selector(save), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: PhotoBrowserLayout())
}


extension PhotoBrowserController: UICollectionViewDataSource, PhotoBrowserCellDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureURLs?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoBrowserCellID, forIndexPath: indexPath) as! PhotoBrowserCell
        cell.backgroundColor = UIColor.randomColor()
        cell.imageURL = pictureURLs![indexPath.row]
        
        cell.photoBrowserCellDelegate = self
        
        return cell
    }
    
    func photoBrowserCellDidClose(cell: PhotoBrowserCell) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


class PhotoBrowserLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        itemSize = UIScreen.mainScreen().bounds.size
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
    }
}