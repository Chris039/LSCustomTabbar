//
//  MainTabBarController.swift
//  SwiftText
//
//  Created by 李松 on 2019/12/27.
//  Copyright © 2019 Chris. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController,RootTabBarDelegate{
    
    var TabBar = LSTabBar()
    var tabBarNormalImgs = ["home-unselect","category-unselect","cart-unselect","mine-unselect"]
    var tabBarSelectImgs = ["home-select","category-select","cart-select","mine-select"]
    var tabBarTitles = ["首页","分类","购物车","我的"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.creatTabBar()
    }
    
    func creatTabBar() {
        let customTabBar: LSTabBar = LSTabBar()
        customTabBar.addDelegate = self
        self.setValue(customTabBar, forKey: "tabBar")
        TabBar = customTabBar
        
        // 设置tabbar子控制器
        self.setRootTaBarVc()
    }
    
    func setRootTaBarVc() {
            
        var Vc: UIViewController?
        
        for i in 0 ..< self.tabBarTitles.count {
            print(self.tabBarTitles[i])
           switch i {
           case 0:
                Vc = HomeViewController()
            case 1:
                Vc = CategoryViewController()
            case 2:
                Vc = CartViewController()
            case 3:
                Vc = MineViewController()
            default:
                break
            }
            
            // 1.创建导航控制器
            let nav = BaseNavigationViewController.init(rootViewController: Vc!)
            // 2.创建tabbarItem
            let barItem = UITabBarItem.init(title: self.tabBarTitles[i], image: UIImage.init(named: self.tabBarNormalImgs[i])?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage.init(named: self.tabBarSelectImgs[i])?.withRenderingMode(.alwaysOriginal))
  
            // 设置标题
            Vc?.title = self.tabBarTitles[i]
            
            // 设置根控制器
            Vc?.tabBarItem = barItem
            
            // 添加到当前控制器
            self.addChild(nav)
            
        }
    }
    
    // 点击中间按钮的方法
    func addClick() {
        print("点击中间按钮的方法")
    }

}


protocol RootTabBarDelegate :NSObjectProtocol{
    func addClick()
}

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let iPhoneX = (ScreenHeight == 812.0 || ScreenHeight == 896.0 ? true :false)
let kBottomSafeSpace = (iPhoneX ? 34.0 : 0.0)

class LSTabBar: UITabBar {
    
    weak var addDelegate: RootTabBarDelegate?
    
    // 懒加载创建一个中间按钮
    private lazy var centerTabBarBtn: UIButton = {
        return UIButton()
    }()
    
    // 视图初始化
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.initView()
        
        self.addSubview(self.centerTabBarBtn)
        self.centerTabBarBtn.setImage(UIImage.init(named: "member-select"), for: .normal)
        self.centerTabBarBtn.adjustsImageWhenHighlighted = false
        self.centerTabBarBtn.addTarget(self, action: #selector(LSTabBar.addButtonClick), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    func initView() {
        
        let backView = UIView.init(frame: CGRect.init(x: 0, y: -10, width: ScreenWidth, height: CGFloat(kBottomSafeSpace+49+10+40)))
        // 加载图片
        let image = UIImage(named: "tabBar_background")
        // 设置不拉伸区域
        let top: CGFloat = 40
        let left: CGFloat = 0
        let bottom: CGFloat = 0
        let right: CGFloat = 0
        
        // 拉伸图片
        let bgImage: UIImage = (image?.resizableImage(withCapInsets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right), resizingMode: .stretch))!
        
        let imageView: UIImageView = UIImageView.init(image: bgImage)
        imageView.contentMode = .scaleToFill
        imageView.frame = backView.frame
        backView.addSubview(imageView)
        
        self.tintColor = .red
        
        self.insertSubview(backView, at: 0)
        
        if #available(iOS 13, *) {
            let appearance = self.standardAppearance.copy()
            appearance.backgroundImage = UIImage.getImageWithColor(.clear, 1)
            appearance.shadowImage = UIImage.getImageWithColor(.clear, 1)
            self.standardAppearance = appearance
        } else {
            self.backgroundImage = UIImage.getImageWithColor(.clear, 1)
            self.shadowImage = UIImage.getImageWithColor(.clear, 1)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width: CGFloat = 54
        self.centerTabBarBtn.frame = CGRect(x: (ScreenWidth - width)/2, y: -14, width: width, height: width);
        self.centerTabBarBtn.layer.cornerRadius = width/2
        
        let tabBarButtonW: CGFloat = ScreenWidth / 5
        var tabBarButtonIndex: Int = 0
        
        for barButton in self.subviews {
            if barButton.isKind(of: NSClassFromString("UITabBarButton")!) {
                // 重新设置frame
                let frame = CGRect(x: CGFloat(tabBarButtonIndex) * tabBarButtonW, y: 0, width: tabBarButtonW, height: 49);
                barButton.frame = frame;

                // 增加索引
                if (tabBarButtonIndex == 1) {
                    tabBarButtonIndex += 1;
                }
                tabBarButtonIndex += 1;
            }
        }
        
        self.bringSubviewToFront(centerTabBarBtn)
    }
    
    /// 重写hitTest方法，监听按钮的点击 让凸出tabbar的部分响应点击
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        } else {
            // 将单线触摸点转换到按钮上生成新的点
             let onButton = self.convert(point, to: self.centerTabBarBtn)
             // 判断新的点是否在按钮上
            if self.centerTabBarBtn.point(inside: onButton, with: event) {
               return centerTabBarBtn
            } else {
                return super.hitTest(point, with: event)
            }
        }
    }
    
    // 点击中间按钮的实现方法
     @objc func addButtonClick() {
        if addDelegate != nil{
            addDelegate?.addClick()
        }
        debugPrint("123456")
     }
}
