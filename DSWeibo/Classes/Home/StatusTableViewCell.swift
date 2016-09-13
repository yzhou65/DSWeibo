//
//  StatusTableViewCell.swift
//  DSWeibo
//
//  Created by xiaomage on 15/9/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

import UIKit
import SDWebImage

/**
 保存cell的重用标识
 NormalCell：原创微博的重用标识
 ForwardCell：转发微博的重用标识
 */
enum StatusTableViewCellIdentifier: String {
    case NormalCell = "NormalCell"
    case ForwardCell = "ForwardCell"
    
    /**
     如果在美剧中利用static修饰一个方法，相当于类中的class修饰方法
     */
    static func cellID(status: Status) -> String {
        return status.retweeted_status != nil ? ForwardCell.rawValue : NormalCell.rawValue
    }
}

class StatusTableViewCell: UITableViewCell {

    /// 保存配图的宽度约束
    var pictureWidthCons: NSLayoutConstraint?
    /// 保存配图的高度约束
    var pictureHeightCons: NSLayoutConstraint?
    /// 保存配图的顶部约束
    var pictureTopCons: NSLayoutConstraint?
    /// status模型
    var status: Status?
        {
        didSet{
            //设置顶部视图topView
            topView.status = status
            
            //正文
            contentLabel.text = status?.text
            
            pictureView.status = status?.retweeted_status != nil ? status?.retweeted_status : status
            //设置配图的尺寸
            //根据模型计算配图的尺寸。注意：计算尺寸需要用到模型，所以要先传递模型
            let size = pictureView.calculateImageSize()
            //设置配图的尺寸
            pictureWidthCons?.constant = size.width
            pictureHeightCons?.constant = size.height
            pictureTopCons?.constant = (size.height == 0) ? 0 : 10
        }
    }
    
    // 自定义一个类需要重写的init方法是 designated
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 初始化UI
        setupUI()
    }
    
    func setupUI()
    {
        // 1.添加子控件
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(footerView)
        
        // 2.布局子控件
        let width = UIScreen.mainScreen().bounds.width
        topView.xmg_AlignInner(type: XMG_AlignType.TopLeft, referView: contentView, size: CGSize(width: width, height: 60))
        contentLabel.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: topView, size: nil, offset: CGPoint(x: 10, y: 10))
        
//       
        
        footerView.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: pictureView, size: CGSize(width: width, height: 44), offset: CGPoint(x: -10, y: 10))
        
        // 添加一个底部约束
        // TODO: 这个地方是有问题的
        //        footerView.xmg_AlignInner(type: XMG_AlignType.BottomRight, referView: contentView, size: nil, offset: CGPoint(x: -10, y: -10))
    }
    
    /**
     用于获取行高
     */
    func rowHeight(status: Status) -> CGFloat {
        //为了能够调用didSet，计算配图的高度
        self.status = status
        
        //强制更新UI
        self.layoutIfNeeded()
        
        //返回底部视图最大y值
        return CGRectGetMaxY(footerView.frame)
    }

        
    // MARK: - 懒加载
    /// topView（包含了头像，昵称，时间，来源，认证图标等）
    private lazy var topView: StatusTableTopView = StatusTableTopView()
    /// 正文
    lazy var contentLabel: UILabel =
    {
        let label = UILabel.createLabel(UIColor.darkGrayColor(), fontSize: 15)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 20
        return label
    }()
    
    /// 配图
    lazy var pictureView: StatusPictureView = StatusPictureView()
    
    /// 底部工具条
    lazy var footerView: StatusTableFooterView = StatusTableFooterView()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

