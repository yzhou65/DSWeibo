//
//  PhotoSelectorViewController.swift
//  图片选择器
//
//  Created by Yue on 9/17/16.
//  Copyright © 2016 fda. All rights reserved.
//

import UIKit

private let YZPhotoSelectorReuseIdentifier = "YZPhotoSelectorReuseIdentifier"
class PhotoSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
    }
    
    private func setupUI() {
        //添加子控件
        view.addSubview(collectionView)
        
        //布局子控件
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["collectionView": collectionView])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["collectionView": collectionView])
        view.addConstraints(cons)
    }

    //MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: PhotoSelectorViewLayout())
        clv.dataSource = self
        clv.registerClass(PhotoSelectorCell.self, forCellWithReuseIdentifier: YZPhotoSelectorReuseIdentifier)
        return clv
    }()
    
    lazy var photoImages = [UIImage]()
}


extension PhotoSelectorViewController: UICollectionViewDataSource, PhotoSelectorCellDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoImages.count + 1
//        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(YZPhotoSelectorReuseIdentifier, forIndexPath: indexPath) as! PhotoSelectorCell
        
        cell.photoSelectorCellDelegate = self
        cell.backgroundColor = UIColor.greenColor()
        
        cell.image = (photoImages.count == indexPath.item) ? nil : photoImages[indexPath.item]

        return cell
    }
    
    func photoSelectorDidAdd(cell: PhotoSelectorCell) {
        /*
         case PhotoLibrary: 照片库（所有的照片、拍照&用iTunes&iPhoto“同步”的照片－不能删除）
         case SavedPhotosAlbum：相册（自己拍照保存的，可以随便删除）
         case Camera：相机
         */
        // 判断能否打开照片库
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            print("无法打开相册")
            return
        }
        
        //创建图片选择器
        let vc = UIImagePickerController()
        vc.delegate = self
        // 设置允许用户编辑选中的图片
        // 开发中如果需要上传头像，那么请让用户编辑之后再上传，这样就可以得到一张正方形的图片，以便于后期处理（圆形）
        vc.allowsEditing = true
        presentViewController(vc, animated: true, completion: nil)
    }
    
    /**
     选中相片之后调用
     
     :param: picker       促发事件的控制器
     :param: image        当前选中的图片
     :param: editingInfo  编辑之后的图片
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        /*
         注意：一般情况下，只要涉及到从相册中获取图片的功能，都需要处理内存
         假如手机只开了某一个app，其启动后会占用20M左右的内存，当内存飙升到500M左右时，系统会发送内存警告，此时就需要释放内存，否则就会闪退
         只要内存释放到100M左右，那么系统就不会闪退此app
         也就是说一个app占用的内存20～100时，是比较安全的内容范围
         */
        // 注意：通过JPEG来压缩图片，图片是不保真的，且苹果不推荐使用JPG图片，因为显示JPG图片的时候压缩非常消耗内存
        let newImage = image.imageScaledWithWidth(300)

        //将当前选中的图片添加到数组中
        photoImages.append(newImage)
        collectionView.reloadData()
        
        //注意：如果实现了该方法，需要我们自己关闭图片选择器
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func photoSelectorDidRemove(cell: PhotoSelectorCell) {
        //从数组中移除当前点击的图片
        let indexPath = collectionView.indexPathForCell(cell)
        photoImages.removeAtIndex(indexPath!.item)
        
        //刷新表格
        collectionView.reloadData()
    }
}

@objc //加上@objc的前缀才能在协议中定义optional的方法
protocol PhotoSelectorCellDelegate: NSObjectProtocol {
    optional func photoSelectorDidAdd(cell: PhotoSelectorCell)
    optional func photoSelectorDidRemove(cell: PhotoSelectorCell)
}

class PhotoSelectorCell: UICollectionViewCell {
    weak var photoSelectorCellDelegate: PhotoSelectorCellDelegate?
    
    var image: UIImage? {
        didSet{
            if image != nil {
                removeButton.hidden = false
                addButton.userInteractionEnabled = false
                addButton.setImage(image, forState: UIControlState.Normal)
            } else {
                removeButton.hidden = true
                addButton.userInteractionEnabled = true
                addButton.setImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    private func setupUI() {
        //添加并布局子控件
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        
        //布局
        addButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        var cons = [NSLayoutConstraint]()
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[addButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addButton": addButton])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[addButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addButton": addButton])
        
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:[removeButton]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["removeButton": removeButton])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-2-[removeButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["removeButton": removeButton])
        
        contentView.addConstraints(cons)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 懒加载
    /// 移除照片的“叉叉”形按钮
    private lazy var removeButton: UIButton = {
        let btn = UIButton()
        btn.hidden = true  //一开始还没有添加任何照片时，不显示。有照片加入后再显示
        btn.setImage(UIImage(named: "compose_photo_close"), forState: UIControlState.Normal)
        btn.addTarget(self, action: #selector(removeBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    /// 添加照片的按钮
    private lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        btn.setImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
        btn.addTarget(self, action: #selector(addBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    func addBtnClick() {
        photoSelectorCellDelegate?.photoSelectorDidAdd!(self)
    }
    
    func removeBtnClick() {
        photoSelectorCellDelegate?.photoSelectorDidRemove!(self)
    }
    
}


class PhotoSelectorViewLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        
        itemSize = CGSize(width: 80, height: 80)
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
