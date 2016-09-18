//
//  PhotoBrowserCell.swift
//  DSWeibo
//
//  Created by Yue on 9/13/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoBrowserCellDelegate: NSObjectProtocol {
    func photoBrowserCellDidClose(cell: PhotoBrowserCell)
}

class PhotoBrowserCell: UICollectionViewCell {
    weak var photoBrowserCellDelegate: PhotoBrowserCellDelegate?
    
    var imageURL: NSURL? {
        didSet {
            //重置属性
            reset()
            
            //显示loading菊花
            activity.startAnimating()
            
            //设置图片
            iconView.sd_setImageWithURL(imageURL) { (image, _, _, _) in
                self.activity.stopAnimating()
                
                // 调整图片的尺寸和位置
                self.setImageViewPosition()
            }
        }
    }
    
    /**
     调整图片显示的位置
     */
    private func setImageViewPosition() {
        //拿到按照宽高比计算之后的图片大小
        let size = self.displaySize(iconView.image!)
        
        //判断图片的高度，是否大于屏幕的高度
        if size.height < UIScreen.mainScreen().bounds.height {
            //小于 短图 -> 设置边距，让图片居中显示
            iconView.frame = CGRect(origin: CGPointZero, size: size)
            let y = (UIScreen.mainScreen().bounds.height - size.height) * 0.5
            self.scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
        }
        else {
            //大于 长图 -> y == 0, 设置scrollView的滚动范围为图片的大小
            iconView.frame = CGRect(origin: CGPointZero, size: size)
            scrollView.contentSize = size
        }
    }
    
    /**
     重置scrollView和imageView的属性。
     如果第一个图被放大，有可能拖到第三个图（重用第一个cell）会显示出问题
     */
    private func reset() {
        //这样就能重置scrollView
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
        
        //重置imageView
        iconView.transform = CGAffineTransformIdentity
    }
    
    /**
     按照图片的宽高比计算图片显示的大小
     */
    private func displaySize(image: UIImage) -> CGSize {
        //拿到图片宽高比
        let scale = image.size.height / image.size.width
        //根据宽高比计算高度
        let width = UIScreen.mainScreen().bounds.width
        let height = width * scale
        
        return CGSize(width: width, height: height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //初始化UI
        setupUI()
    }
    
    private func setupUI() {
        //添加子控件
        contentView.addSubview(scrollView)
        scrollView.addSubview(iconView)
    
        //布局子控件
        scrollView.frame = UIScreen.mainScreen().bounds
        
        // 处理缩放
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 0.5
        
        //监听图片点击，达到点击图片后能关闭的效果
        let tap = UITapGestureRecognizer(target: self, action: #selector(closePicture))
        iconView.userInteractionEnabled = true //因为图片默认无法点击
        iconView.addGestureRecognizer(tap)
    }
    
    //MARK: - 监听
    /**
     关闭照片浏览器
     */
    func closePicture() {
        photoBrowserCellDelegate?.photoBrowserCellDidClose(self)
    }
    
    //MARK: - 懒加载
    private lazy var scrollView: UIScrollView = UIScrollView()
    lazy var iconView: UIImageView = UIImageView()
    private lazy var activity: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension PhotoBrowserCell: UIScrollViewDelegate {
    
    /**
     告诉系统需要缩放哪个控件
     */
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return iconView
    }
    
    /**
     pinch缩放图片完成后调用。此时需要重新调整配图的居中性
     view：被缩放的视图
     */
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
//        print("scrollViewDidEndZooming")
        
        //注意：缩放的本质是修改了transform，而修改transform不会影响到bounds，只有frame会受到影响
        var offsetX = (UIScreen.mainScreen().bounds.width - view!.frame.width) * 0.5
        var offsetY = (UIScreen.mainScreen().bounds.height - view!.frame.height) * 0.5
        offsetX = offsetX < 0 ? 0 : offsetX
        offsetY = offsetY < 0 ? 0 : offsetY
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
