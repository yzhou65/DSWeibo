//
//  EmoticonPackage.swift
//  表情键盘界面布局
//
//  Created by Yue on 9/14/16.
//  Copyright © 2016 小码哥. All rights reserved.
//

/*
 结构：
 1. 加载emoticons.plist拿到魅族表情的路径
 emoticons.plist(存储了所有表情的数据的字典)
 |----packages(字典数组)
 |----id(存储了对应组表情对应的文件夹)
 
 2. 根据拿到的路径加载对应组表情的info.plist
 info.plist（字典）
 |----id(当前组表情文件夹的名称)
 |----group_name_cn(组的名称)
 |----emoticons(字典数组，里面存储了所有表情)
 |----chs（表情对应的文字）
 |----png(表情对应的图片）
 |----code(emoji表情对应的十六进制字符串）
 
 */
import UIKit

class EmoticonPackage: NSObject {
    /// 当前组表情文件夹的名称
    var id: String?
    /// 组的名称
    var group_name_cn: String?
    /// 字典数组，里面存储了所有表情
    var emoticons: [Emoticon]?
    
    /// 为了使所有表情只加载一次，可以引入一个static变量packageList，这样就不需要多次调用loadPackage方法了
    static let packageList:[EmoticonPackage] = EmoticonPackage.loadPackages()
    
    /**
     获取所有组的表情数组
     浪小花 -> 一组 -> 所有的表情模型（emoticons）
     默认 -> 一组 -> 所有的表情模型（emoticons）
     emoji -> 一组 -> 所有的表情模型（emoticons）
     */
    private class func loadPackages() -> [EmoticonPackage] {
        var packages = [EmoticonPackage]()
        //创建“最近”组
        let pk = EmoticonPackage(id: "")
        pk.group_name_cn = "最近"
        pk.emoticons = [Emoticon]()
        pk.appendEmptyEmoticons()
        packages.append(pk)
        
        //加载emoticons.plist
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        let dict = NSDictionary(contentsOfFile: path)!

        //从emoticons中获取packages
        let dictArray = dict["packages"] as! [[String: AnyObject]]
        
        //遍历packages数组
        for d in dictArray {
            //取出ID，创建对应的组
            let package = EmoticonPackage(id: d["id"]! as! String)
            packages.append(package)
            package.loadEmoticons()
            package.appendEmptyEmoticons()
        }
        
        //取出ID
        
        return packages
    }
    
    /**
     加载每一组中所有的表情
     */
    func loadEmoticons() {
        let emoticonDict = NSDictionary(contentsOfFile: infoPath("info.plist"))
        group_name_cn = emoticonDict!["group_name_cn"] as? String
        let dictArray = emoticonDict!["emoticons"] as! [[String: String]]
        
        var index = 0
        emoticons = [Emoticon]()
        for dict in dictArray {
            if index == 20 {
                emoticons?.append(Emoticon(isRemoveButton: true))
                index = 0
            }
            emoticons?.append(Emoticon(dict: dict, id: id!))
            index += 1
            
        }
    }
    
    /**
     追加空白按钮
     如果某页不足21个，就添加一些空白按钮补齐
     */
    func appendEmptyEmoticons() {
        let count = emoticons!.count % 21
        
        //追加空白按钮
        for _ in count..<20 {
            emoticons?.append(Emoticon(isRemoveButton: false)) //追加空白
        }
        //追加一个删除按钮
        emoticons?.append(Emoticon(isRemoveButton: true))
    }
    
    /**
     给“最近”添加表情
     */
    func appendRecentEmoticons(emoticon: Emoticon) {
        if emoticon.isRemoveButton {
            return
        }
        
        //判断当前点击的表情是否已经添加到最近数组中
        let contains = emoticons!.contains(emoticon)
        if !contains {
            emoticons?.removeLast() //删除“退格”按钮
            emoticons?.append(emoticon)
        }
        
        //排序数组。根据表情的使用次数排序
        var result = emoticons?.sort({ (e1, e2) -> Bool in
            return e1.times > e2.times
        })
        //删除多余表情
        if !contains {
            result?.removeLast()
            result?.append(Emoticon(isRemoveButton: true)) //最后添加一个“删除”按钮
        }
        emoticons = result
    }
    
    /**
     获取指定文件全路径
     */
    func infoPath(fileName: String) -> String {
        return (EmoticonPackage.emoticonPath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent(fileName)
    }
    
    /**
     获取微博表情的主路径
     */
    class func emoticonPath() -> NSString {
        return (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent("Emoticons.bundle")
    }
    
    init(id: String){
        self.id = id
    }
}

class Emoticon: NSObject {
    /// 表情对应的文字
    var chs: String?
    /// 表情对应的图片
    var png: String? {
        didSet{
            imagePath = (EmoticonPackage.emoticonPath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent(png!)
        }
    }

    /// emoji表情对应的十六进制字符串
    var code: String? {
        didSet{
            //从字符串中取出十六进制的数
            //创建scanner，可以从字符串中提取想要的数据
            let scanner = NSScanner(string: code!)
            
            //将十六进制转换为字符串
            var result:UInt32 = 0
            scanner.scanHexInt(&result)
            emojiStr = "\(Character(UnicodeScalar(result)))"
        }
    }
    
    var emojiStr: String?
    /// 当前组表情文件夹的名称
    var id: String?
    /// 表情包全路径
    var imagePath: String?
    /// 标记是否是删除按钮
    var isRemoveButton: Bool = false
    
    /// 记录当前表情被使用的次数
    var times: Int = 0
    
    init(isRemoveButton: Bool) {
        super.init()
        self.isRemoveButton = isRemoveButton
    }
    
    init(dict: [String: String], id: String){
        super.init()
        self.id = id
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
}
