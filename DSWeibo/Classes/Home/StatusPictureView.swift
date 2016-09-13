//
//  StatusPictureView.swift
//  DSWeibo
//
//  Created by Yue on 9/12/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit
import SDWebImage

let YZPictureViewCellReuseIndentifier = "YZPictureViewCellReuseIndentifier"
class StatusPictureView: UICollectionView {
    var status: Status? {
        didSet{
            //刷新表格
            reloadData()
        }
    }
    
    private var pictureLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    init() {
        super.init(frame: CGRectZero, collectionViewLayout: pictureLayout)
        
        //注册cell
        registerClass(PictureViewCell.self, forCellWithReuseIdentifier: YZPictureViewCellReuseIndentifier)
        
        //设置数据源
        dataSource = self
        
        //设置cell之间的间隙
        pictureLayout.minimumInteritemSpacing = 10
        pictureLayout.minimumLineSpacing = 10
        
        //设置配图的背景颜色
        backgroundColor = UIColor.darkGrayColor()
    }
    
    /**
     计算配图尺寸.
     */
    func calculateImageSize() -> CGSize {
        //取出配图个数
        let count = status?.storedPicURLS?.count
        //如果没有配图，则返回CGSizeZero
        if count == 0 || count == nil {
            return CGSizeZero
        }
        
        //如果只有一张配图，返回图片的实际大小
        if count == 1 {
            //取出缓存图片
            let key = status?.storedPicURLS!.first?.absoluteString
            let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key!)
            
            pictureLayout.itemSize = image.size
            //返回缓存图片尺寸
            return image.size
        }
        
        //如果是4张配图，计算田字格的大小
        let width = 90
        let margin = 10
        pictureLayout.itemSize = CGSize(width: width, height: width)
        if count == 4 {
            let viewWidth = width * 2 + margin
            return CGSize(width: viewWidth, height: viewWidth)
        }
        
        //如果是其它（多张），计算九宫格的大小
        let colNumber = 3
        let rowNumber = (count! - 1) / colNumber + 1
        let viewWidth = colNumber * width + (colNumber - 1) * margin
        let viewHeight = rowNumber * width + (rowNumber - 1) * margin
        return CGSize(width: viewWidth, height: viewHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /**
     将PictureViewCell定义为一个inner class
     */
    private class PictureViewCell: UICollectionViewCell {
        //定义属性接收外界传入的数据
        var imageURL: NSURL? {
            didSet{
                iconImageView.sd_setImageWithURL(imageURL!)
            }
        }
        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            //初始化UI
            setupUI()
        }
        
        private func setupUI() {
            //添加子控件
            contentView.addSubview(iconImageView)
            //布局子控件
            iconImageView.xmg_Fill(contentView)
        }
        
        //MARK: - 懒加载
        private lazy var iconImageView:UIImageView = UIImageView()
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension StatusPictureView: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return status?.storedPicURLS?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //取出cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(YZPictureViewCellReuseIndentifier, forIndexPath: indexPath) as! PictureViewCell
        //设置数据
        //        cell.backgroundColor = UIColor.greenColor()
        cell.imageURL = status?.storedPicURLS![indexPath.item]
        
        return cell
    }

}


