//
//  StatusForwardTableViewCell.swift
//  DSWeibo
//
//  Created by Yue on 9/12/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

class StatusForwardTableViewCell: StatusTableViewCell {
    
    override var status: Status? {
        didSet{
            let name = status?.retweeted_status?.user?.name ?? ""
            let text = status?.retweeted_status?.text ?? ""
            forwardLabel.text = name + ": " + text
        }
    }

    override func setupUI() {
        super.setupUI()
        
        //添加子控件
//        contentView.addSubview(forwardContent) //错误。因为先添加了父控件的内容，再添加forwardContent会覆盖pictureView
        contentView.insertSubview(forwardContent, belowSubview: pictureView)
        contentView.insertSubview(forwardLabel, aboveSubview: forwardContent)
        
        //布局子控件
        //布局转发背景
        forwardContent.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: contentLabel, size: nil, offset: CGPoint(x: -10, y: 10))
        forwardContent.xmg_AlignVertical(type: XMG_AlignType.TopRight, referView: footerView, size: nil)
        
        //布局转发正文
        forwardLabel.text = "fsdfjaljafldlfjlsajdflajlejdflaj"
        forwardLabel.xmg_AlignInner(type: XMG_AlignType.TopLeft, referView: forwardContent, size: nil, offset: CGPoint(x: 10, y: 10))
        
        //重新调整转发配图的位置
        let cons = pictureView.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: forwardLabel, size: CGSize(width: 290, height:290), offset: CGPoint(x: 0, y: 10))
        pictureWidthCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.Width)
        pictureHeightCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.Height)
        pictureTopCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.Top)
    }
    
    //MARK: - 懒加载
    private lazy var forwardLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.darkGrayColor(), fontSize: 15)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 20
        return label
    }()
    
    private lazy var forwardContent: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        return btn
    }()
}
