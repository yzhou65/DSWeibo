//
//  QRCodeViewController.swift
//  DSWeibo
//
//  Created by Yue on 9/7/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, UITabBarDelegate {
    ///扫描容器高度约束
    @IBOutlet weak var containerHeightCons: NSLayoutConstraint!
    
    ///扫描线视图
    @IBOutlet weak var scanLineView: UIImageView!
    
    ///扫描线视图的顶部约束
    @IBOutlet weak var scanLineCons: NSLayoutConstraint!
    
    ///底部试图
    @IBOutlet weak var customTabBar: UITabBar!
    
    ///保存扫描到的结果
    @IBOutlet weak var resultLabel: UILabel!
    
    ///监听名片按钮点击
    @IBAction func myCardBtnClick(sender: AnyObject) {
        let vc = QRCodeCardViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func closeBtnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置底部视图默认选中“二维码”
        customTabBar.selectedItem = customTabBar.items![0]
        
        customTabBar.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //开时“冲击波”动画
        startAnimation()
        
        //开时扫描
        startScan()
    }
    
    /**
     扫描二维码
     */
    private func startScan(){
        //判断是否能将输入添加到会话
        if !session.canAddInput(deviceInput) {
            return
        }
        
        //判断是否能将输出添加到会话
        if !session.canAddOutput(output) {
            return
        }
        
        //将输入和输出都添加到会话
        session.addInput(deviceInput)
        session.addOutput(output)
        
        //设置输出能够解析的数据类型
        //注意：设置能够解析的数据类型，一定要在输出对象添加到会话之后设置，否则会报错
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        //设置输出对象的代理，只要解析成功就会通知代理
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        //系统自带的二维码扫描不支持只扫描一张图片（加入屏幕上某区域有多个二维码）。只能设置让二维码只有出现在某一块区域才去扫描
        output.rectOfInterest = CGRectMake(0.0, 0.0, 1.0, 1.0)
        
        //添加预览图层。要避免盖住“扫描线冲击波”
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        
        //添加绘制图层到预览图层上
        previewLayer.addSublayer(drawLayer)
        
        //告诉session开始扫描
        session.startRunning()
    }
    
    /**
     执行动画
     */
    private func startAnimation() {
        //让约束从顶部开始
        self.scanLineCons.constant = -self.containerHeightCons.constant
        //强制更新界面
        self.scanLineView.layoutIfNeeded()
        
        //执行“冲击波”动画
        UIView.animateWithDuration(5.0, animations: {
            //修改约束
            self.scanLineCons.constant = self.containerHeightCons.constant
            
            //设置动画的次数
            UIView.setAnimationRepeatCount(MAXFLOAT)
            
            //强制更新界面
            self.scanLineView.layoutIfNeeded()
        })
    }
    
    //MARK: -UITabBarDelegate
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        //修改容器高度
        if item.tag == 1 {
//            print("qrcode")
            self.containerHeightCons.constant = 300
        } else {
//            print("barcode")
            
            self.containerHeightCons.constant *= 0.5
        }
        
        //停止动画再开时
        scanLineView.layer.removeAllAnimations()
        startAnimation()
    }

    //MARK: -懒加载
    //会话. 以下是懒加载的一种简单写法, 前提是不需要传入参数
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    //拿到输入设备
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        //获取摄像头
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        //创建输入对象
        do{
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch{
            print(error)
            return nil
        }
    }()
    
    //拿到输出对象
    private lazy var output: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    //创建预览图层
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session) //闭包中访问成员属性要加上self
        layer.frame = UIScreen.mainScreen().bounds
        return layer
    }()
    
    //创建用于绘制边线的图层
    private lazy var drawLayer: CALayer = {
        let layer = CALayer()
        layer.frame = UIScreen.mainScreen().bounds
        return layer
    }()
}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate
{
    /**
     只要解析到数据就会调用
     */
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        //清空图层
        clearCorners()
        
        //获取扫描到的数据
        //注意：要使用stringValue将metadataObjects中的对象转为string
        resultLabel.text = metadataObjects.last?.stringValue
        resultLabel.sizeToFit()
        
        //获取扫描到的二维码位置
        //转换坐标
        for obj in metadataObjects
        {
            //判断当前获取到的数据，机器是否可以识别
            if obj is AVMetadataMachineReadableCodeObject {
                //将坐标转换成界面可识别的坐标
                let codeObj = previewLayer.transformedMetadataObjectForMetadataObject(obj as! AVMetadataObject) as! AVMetadataMachineReadableCodeObject
                
                //绘制图形
                drawCorners(codeObj)
            }
        }
    }
    
    /**
     扫描到二维码后，绘制一个边框来指示扫描到了
     */
    private func drawCorners(codeObj: AVMetadataMachineReadableCodeObject){
        if codeObj.corners.isEmpty {
            return
        }
        
        //创建一个图层
        let layer = CAShapeLayer()
        layer.lineWidth = 4
        layer.strokeColor = UIColor.greenColor().CGColor
        layer.fillColor = UIColor.clearColor().CGColor
        
        //创建路径
//        layer.path = UIBezierPath(rect: CGRect(x: 100, y: 100, width: 200, height: 200)).CGPath
        let path = UIBezierPath()
        var point = CGPointZero
        var index: Int = 0
        //从corners数组中取出第0个，将这个字典中的x/y赋值给point
        CGPointMakeWithDictionaryRepresentation((codeObj.corners[index++] as! CFDictionaryRef), &point)
        path.moveToPoint(point)
        
        //移动到其他点
        while index < codeObj.corners.count
        {
            CGPointMakeWithDictionaryRepresentation((codeObj.corners[index++] as! CFDictionaryRef), &point)
            path.addLineToPoint(point)
        }
        
        //关闭路径
        path.closePath()
        
        layer.path = path.CGPath
        
        //将绘制好的图层添加到drawLayer上
        drawLayer.addSublayer(layer)
    }
    
    /**
     清空边线
     */
    private func clearCorners(){
        if drawLayer.sublayers == nil || drawLayer.sublayers?.count == 0 {
            return
        }
        
        for sublayer in drawLayer.sublayers!
        {
            sublayer.removeFromSuperlayer()
        }
    }
}
