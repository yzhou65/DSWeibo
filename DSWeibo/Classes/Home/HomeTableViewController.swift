//
//  HomeTableViewController.swift
//  DSWeibo
//
//  Created by Yue on 9/6/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit
import SVProgressHUD

let YZHomeReuseIdentifier = "YZHomeReuseIdentifier"
class HomeTableViewController: BaseTableViewController {
    ///用于保存微博数组
    var statuses:[Status]? {
        didSet{
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        SVProgressHUD.showInfoWithStatus("我来了")
        
        //如果没有登录，就要设置未登录界面信息
        if !userLogin {
            visitorView?.setupVisitorInfo(true, imageName: "visitordiscover_feed_image_house", message: "关注一些人，会这里看看有什么惊喜")
            return
        }
        
        //初始化导航条
        setupNav()
        
        //注册通知，监听菜单的弹出与关闭
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(change), name: YZPopoverAnimatorWillShow, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(change), name: YZPopoverAnimatorWillDismiss, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showPhotoBrowser), name: YZStatusPictureViewSelected, object: nil)
        
        //注册2个cell
        tableView.registerClass(StatusNormalTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellIdentifier.NormalCell.rawValue)
        tableView.registerClass(StatusForwardTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellIdentifier.ForwardCell.rawValue)
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //添加自定义的下拉刷新控件
        /*
        refreshControl = UIRefreshControl()
        let refreshView = UIView()
        refreshView.backgroundColor = UIColor.redColor()
        refreshView.frame = CGRect(x: 0, y: 0, width: 375, height: 60)
        refreshControl?.addSubview(refreshView)
        */
        refreshControl = HomeRefreshViewControl()
        refreshControl?.addTarget(self, action: #selector(loadBlogData), forControlEvents: UIControlEvents.ValueChanged)
        
        newStatusLabel.hidden = false
        
        //加载微博数据
        loadBlogData()
    }
    
    /**
     显示图片浏览器
     */
    func showPhotoBrowser(note: NSNotification) {
//        print(note.userInfo)
        //注意：通过通知传递数据，一定要判断数据是否存在
        guard let indexPath = note.userInfo![YZStatusPictureViewIndexKey] as? NSIndexPath else {
            print("No indexPath")
            return
        }
        
        guard let urls = note.userInfo![YZStatusPictureViewURLsKey] as? [NSURL] else {
            print("No pictures")
            return
        }
        
        //创建图片浏览器
        let vc = PhotoBrowserController(index: indexPath.item, urls: urls)
        
        //modal图片浏览器
        presentViewController(vc, animated: true, completion: nil)
    }
    
    deinit {
        //移除通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /// 定义变量记录当前是上拉还是下拉
    var pullupRefreshFlag = false
    /**
     获取微博数据
     如果想调用一个私有方法：
     1. 去掉private
     2. 加上@objc的前缀，当作OC方法来处理。因为OC可以运行时再寻找方法，OC中没有private的概念
     */
    @objc private func loadBlogData() {
        //loadStatuses内部发送异步请求，所以为了保证请求结束后再赋值给statuses就要使用闭包，而不是self.statuses = Status.loadStatuses()
        
        /*
         默认返回最新20条数据
         since_id：会返回比since_id大的微博
         max_id：会返回小于等于max_id的微博
         
         每条微博都有一个微博ID，而且微博ID越后面发送的微博，其微博ID越大，递增
         新浪返回给我们的微博数据，是从大到小的返回的
        */
        /// 默认当做下拉处理
        var since_id = statuses?.first?.id ?? 0
        var max_id = 0
        
        // 判断是否是上拉
        if pullupRefreshFlag {
            since_id = 0
            max_id = statuses?.last?.id ?? 0
        }
        
        Status.loadStatuses(since_id, max_id: max_id) { (models, error) in
            //结束刷新动画
            self.refreshControl?.endRefreshing()
            
            if error != nil {
                return
            }
            
            // 下拉刷新
            if since_id > 0 {
                //如果是下拉刷新，就将获取到的数据，拼接再原有数据前面. Swift中可直接用＋来合并两个类型相同的数组
                self.statuses = models! + self.statuses!
                
                // 显示刷新提醒
                self.showNewStatusCount(models?.count ?? 0)
            } else if max_id > 0 {
                //如果是上拉加载更多，就将获取到的数据，拼接在原有数据的后面
                self.statuses = self.statuses! + models!
            }
            else {
                self.statuses = models
            }
        }
    }
    
    /**
     此方法会被两次调用
     */
    private func showNewStatusCount(count: Int) {
        newStatusLabel.alpha = 1.0
        newStatusLabel.text = (count == 0) ? "没有刷新到新微博数据" : "刷新到\(count)条微博数据"
        
        //动画，记录提醒控件的fram
        /*
         let rect = newStatusLabel.frame
        UIView.animateWithDuration(1, animations: {
            UIView.setAnimationRepeatAutoreverses(true)
            self.newStatusLabel.frame = CGRectOffset(rect, 0, 3 * rect.height)
            }) { (_) in
                self.newStatusLabel.frame = rect
        }
        */
        
        //也可以用transform来做
        UIView.animateWithDuration(1.5, animations: {
            self.newStatusLabel.transform = CGAffineTransformMakeTranslation(0, self.newStatusLabel.frame.height)
            }) { (_) in
                UIView.animateWithDuration(1.5, animations: {
                    self.newStatusLabel.transform = CGAffineTransformIdentity
                    }, completion: { (_) in
                        self.newStatusLabel.hidden = true
                })
        }
    }
    
    /**
     监听菜单的弹出与关闭，修改标题按钮的状态
     */
    func change() {
        //修改标题按钮的状态
        let titleBtn = navigationItem.titleView as! TitleButton
        titleBtn.selected = !titleBtn.selected
    }
    
    /**
     初始化导航条
     */
    private func setupNav() {
        /*
        //左边按钮
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "navigationbar_friendattention"), forState: UIControlState.Normal)
        leftBtn.setImage(UIImage(named: "navigationbar_friendattention_highlighted"), forState: UIControlState.Highlighted)
        leftBtn.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        //右边按钮
        let rightBtn = UIButton()
        rightBtn.setImage(UIImage(named: "navigationbar_pop"), forState: UIControlState.Normal)
        rightBtn.setImage(UIImage(named: "navigationbar_pop_highlighted"), forState: UIControlState.Highlighted)
        rightBtn.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        */
        
        //封装的设置左右按钮的方法
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("navigationbar_friendattention", target: self, action: #selector(leftItemClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem.createBarButtonItem("navigationbar_pop", target: self, action: #selector(rightItemClick))
        
        //初始化标题按钮
        let titleBtn = TitleButton()
        titleBtn.setTitle("Barney's fortress", forState: UIControlState.Normal)
        
        titleBtn.addTarget(self, action: #selector(titleBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.titleView = titleBtn
    }
    
    /**
     监听首页导航条中间按钮的点击
     */
    func titleBtnClick(btn: TitleButton) {
        //修改箭头方向
//        btn.selected = !btn.selected //通知方法中改过了，此处不需要再改
        
        //弹出菜单
        let sb = UIStoryboard(name: "PopoverViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        
        //设置专场代理和转场
        //默认情况下，modal会移除以前控制器的view，替换为当前弹出的view
        //如果自定义转场，那么就不会移除以前控制器的view
//        vc?.transitioningDelegate = self
        
        //用自己作为转场动画代理不合适，改用一个PopoverAnimator对象来管理
        vc?.transitioningDelegate = popoverAnimator
        vc?.modalPresentationStyle = UIModalPresentationStyle.Custom //这里用自定义转场样式，而不是Popover，这样就不会移除以前的控制器view，而是直接盖上面modal
        presentViewController(vc!, animated: true, completion: nil)
    }
    
    func leftItemClick(){
        print(#function)
    }
    
    /**
     监听首页导航条右边的按钮
     */
    func rightItemClick(){
//        print(#function)
        
        let sb = UIStoryboard(name: "QRCodeViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        presentViewController(vc!, animated: true
            , completion: nil)
    }
    
    //MARK: - 懒加载［
    /**
     一定要定义一个属性来保存自定义转场对象，否则会报错
     */
    private lazy var popoverAnimator: PopoverAnimator = {
        let pa = PopoverAnimator()
        pa.presentFrame = CGRect(x: 100, y: 56, width: 200, height: 350)
        return pa
    }()
    
    /// 刷新提醒控件
    private lazy var newStatusLabel: UILabel = {
        let label = UILabel()
        let height: CGFloat = 44
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 44)
        
        label.backgroundColor = UIColor.redColor()
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14)
        label.alpha = 0.0
        
        //添加label到界面上
//        self.tableView.addSubview(label)
        
        self.navigationController?.navigationBar.insertSubview(label, atIndex: 0)
        
        
        //添加label到界面
        return label
    }()
    
    /// 微博行高的缓存，利用字典作为容器，key就是微博的id，value是行高
    var rowCache: [Int: CGFloat] = [Int: CGFloat]()
    
    /**
     如果不停刷微博会导致缓存太多行高。所以当接收到内存警告时，清空rowCache
     */
    override func didReceiveMemoryWarning() {
        //清空缓存
        rowCache.removeAll()
    }
}

extension HomeTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let status = statuses![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(StatusTableViewCellIdentifier.cellID(status), forIndexPath: indexPath) as! StatusTableViewCell
        
        //设置cell的数据
        cell.status = status
        
        //判断是否滚动到了最后一行
        let count = statuses?.count ?? 0
        if indexPath.row == (count - 1) {
            pullupRefreshFlag = true
            loadBlogData()  //获取更多微博数据
        }
        
        
        return cell
    }
    
    
    /**
     返回行高。此方法调用非常频繁
     */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //取出对应行模型
        let status = statuses![indexPath.row]
        
        //判断缓存中有否行高
        if let height = rowCache[status.id] {
//            print("height from cache")
            return height
        }
        
        //拿到对应cell
        //注意：不要使用tableView.dequeueReusableCellWithIdentifier(identifier: String, forIndexPath: NSIndexPath)，会导致方法的循环调用
        let cell = tableView.dequeueReusableCellWithIdentifier(StatusTableViewCellIdentifier.cellID(status)) as! StatusTableViewCell
        
        //拿到对应行的行高
        let rowHeight = cell.rowHeight(status)
        
        //缓存行高
        rowCache[status.id] = rowHeight
//        print("recalculate height")
        
        return rowHeight
    }
}
