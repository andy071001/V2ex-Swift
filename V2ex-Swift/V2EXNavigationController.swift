//
//  V2EXNavigationController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/13/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit



class V2EXNavigationController: UINavigationController {
    
    /// 毛玻璃效果的 navigationBar 背景
    var frostedView:UIToolbar?
    /// navigationBar 阴影
    var shadowImage:UIImage?
    /// navigationBar 背景透明度
    var navigationBarAlpha:CGFloat {
        get{
            return  self.frostedView!.alpha
        }
        set {
            var value = newValue
            if newValue > 1 {
                value = 1
            }
            else if value < 0 {
                value = 0
            }
            self.frostedView!.alpha = newValue
            self.navigationBar.layer.shadowOpacity = Float(value * 0.35)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.layer.shadowRadius = 0.33
        self.navigationBar.layer.shadowOffset = CGSizeMake(0, 0.33)
        self.navigationBar.layer.shadowOpacity = 0.4
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true);
        
        
        self.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
        
        self.navigationBar.titleTextAttributes = [
            NSFontAttributeName : v2Font(18),
            NSForegroundColorAttributeName : V2EXColor.colors.v2_TopicListTitleColor
        ]
        
        self.navigationBar.setBackgroundImage(createImageWithColor(UIColor.clearColor()), forBarMetrics: .Default)
        
        let maskingView = UIView()
        maskingView.userInteractionEnabled = false
        maskingView.backgroundColor = UIColor(white: 0, alpha: 0.0);
        self.navigationBar.insertSubview(maskingView, atIndex: 0);
        
        maskingView.snp_makeConstraints{ (make) -> Void in
            make.left.bottom.right.equalTo(maskingView.superview!)
            make.top.equalTo(maskingView.superview!).offset(-20);
        }
        
        self.frostedView = UIToolbar()
        self.frostedView!.userInteractionEnabled = false
        self.frostedView!.clipsToBounds = true
        self.frostedView!.barStyle = .Default
        maskingView.addSubview(self.frostedView!);
        
        self.frostedView!.snp_makeConstraints{ (make) -> Void in
            make.top.bottom.left.right.equalTo(maskingView);
        }
    }
}
