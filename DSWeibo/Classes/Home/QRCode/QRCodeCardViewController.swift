//
//  QRCodeCardViewController.swift
//  DSWeibo
//
//  Created by Yue on 9/8/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit
import AFNetworking

class QRCodeCardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //设置标题
        navigationItem.title = "我的图片"
        //添加图片容器
        view.addSubview(iconView)
        
        //布局图片容器
        iconView.xmg_AlignInner(type: XMG_AlignType.Center, referView:view, size: CGSize(width: 200, height: 200))
        
        //生成二维码
        let qrcodeImage = createQRCodeImage()
        
        //将生成好的二维码添加到图片容器上
        iconView.image = qrcodeImage
    }
    
    private func createQRCodeImage() -> UIImage {
        //创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        //还原滤镜的默认属性
        filter?.setDefaults()
        //设置需要生成二维码的数据
        filter?.setValue("即刻江南".dataUsingEncoding(NSUTF8StringEncoding), forKey: "inputMessage")
        
        //从滤镜中取出生成好的图片
        let ciImage = filter?.outputImage
        
        //系统默认的方法取得的二维码图片很模糊，所以下面自定义取二维码图片的方法
//        return UIImage(CIImage: ciImage!)
        
        let bgImage = createNonInterpolatedUIImageFromCIImage(ciImage!, size: 300)
        
        //创建一个头像
        let icon = UIImage(named:"nange.jpg")
        
        //合成图片（二维码和头像合并）
        let newImage = createImage(bgImage, iconImage: icon!)
        
        //返回生成好的二维码
        return newImage
    }
    
    /**
     合成图片。传入背景图片和头像图片。
     注意：头像图片不能盖住二维码上的3个重要定位正方形
     */
    private func createImage(bgImage:UIImage, iconImage:UIImage) -> UIImage{
        //开启图片上下文
        UIGraphicsBeginImageContext(bgImage.size)
        //绘制背景图片
        bgImage.drawInRect(CGRect(origin: CGPointZero, size: bgImage.size))
        //绘制头像
        let width:CGFloat = 50.0
        let height = width
        let x = (bgImage.size.width - width) * 0.5
        let y = (bgImage.size.height - height) * 0.5
        iconImage.drawInRect(CGRect(x: x, y: y, width: width, height: height))
        //取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        //返回合成好的图片
        return newImage
    }
    
    /**
     根据CIIMage生成指定大小的高清UIImage
     */
    private func createNonInterpolatedUIImageFromCIImage(image:CIImage, size:CGFloat) -> UIImage {
        let extent: CGRect = CGRectIntegral(image.extent)
        let scale: CGFloat = min(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent))
        
        //创建bitmap
        let width = CGRectGetWidth(extent) * scale
        let height = CGRectGetHeight(extent) * scale
        let cs: CGColorSpaceRef = CGColorSpaceCreateDeviceGray()!
        let bitmapRef = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, cs, 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImageRef = context.createCGImage(image, fromRect: extent)
        
        CGContextSetInterpolationQuality(bitmapRef, CGInterpolationQuality.None)
        CGContextScaleCTM(bitmapRef, scale, scale)
        CGContextDrawImage(bitmapRef, extent, bitmapImage)
        
        //保存bitmap到图片
        let scaledImage: CGImageRef = CGBitmapContextCreateImage(bitmapRef)!
        
        return UIImage(CGImage: scaledImage)
    }

    //MARK: - 懒加载
    private lazy var iconView: UIImageView = UIImageView()
    
}
