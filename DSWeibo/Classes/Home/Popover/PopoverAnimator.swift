//
//  PopoverAnimator.swift
//  DSWeibo
//
//  Created by Yue on 9/7/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

//定义敞亮保存通知的名称
let YZPopoverAnimatorWillShow = "YZPopoverAnimatorWillShow"
let YZPopoverAnimatorWillDismiss = "YZPopoverAnimatorWillDismiss"

class PopoverAnimator: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning
{
    //记录当前是否是展开
    var isPresent: Bool = false
    
    ///定义属性保存菜单的大小
    var presentFrame = CGRectZero
    
    //实现代理方法，告诉系统谁来负责转场动画
    //UIPresentationController是ios8推出的专门用于负责转场动画的
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        let pc = PopoverPresentationController(presentedViewController: presented, presentingViewController: presenting)
        
        //设置菜单的大小
        pc.presentFrame = presentFrame
        
        return pc
    }
    
    // MARK: 只要实现了以下方法，那么系统自带的默认动画就没有了，所有东西都需要程序员手动实现
    
    /**
     展现view的时候调用，告诉系统谁来负责modal的展现动画
     */
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = true
        
        //发送通知，通知控制器即将展开
        NSNotificationCenter.defaultCenter().postNotificationName(YZPopoverAnimatorWillShow, object: self)
        return self
    }
    
    /**
     关闭view的时候调用，告诉系统谁来负责Modal的消失动画
     */
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = false
        
        //发送通知，通知控制器即将关闭
        NSNotificationCenter.defaultCenter().postNotificationName(YZPopoverAnimatorWillDismiss, object: self)
        return self
    }
    
    //MARK: - UIViewControllerAnimatedTransitioning的方法
    /**
     返回动画时长
     */
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    /**
     告诉系统执行怎样的动画，无论是展现还是消失都会调用这个方法
     */
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresent{
            //展开动画
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            toView.transform = CGAffineTransformMakeScale(1.0, 0.0)
            
            //注意：一定要将试图添加到容器
            transitionContext.containerView()?.addSubview(toView)
            
            //设置锚点（从那个点开始展开view）
            toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            
            //执行动画
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                //清空transform
                toView.transform = CGAffineTransformIdentity
            }) { (_) in
                //动画执行完毕要告诉系统. 如果不写可能会导致未知错误
                transitionContext.completeTransition(true)
            }
        }
        else {
            //关闭动画
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                //注意：犹豫CGFloat不准确的，所以如果写0.0会没有动画.因此在
                fromView.transform = CGAffineTransformMakeScale(1.0, 0.00001)
                }, completion: { (_) in
                    //动画执行完毕要告诉系统. 如果不写可能会导致未知错误
                    transitionContext.completeTransition(true)
            })
        }
    }
}
