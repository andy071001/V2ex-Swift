//
//  UIButton+Extension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/29/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

extension UIButton {
    class func roundedButton() -> UIButton {
        let btn = UIButton(type: .Custom)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 3
        btn.backgroundColor  = colorWith255RGB(80, g: 97, b: 109)
        btn.titleLabel!.font = v2Font(14)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        return btn
    }
}
