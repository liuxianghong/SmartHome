//
//  LoginButton.swift
//  SmartHome
//
//  Created by 刘向宏 on 16/1/13.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import UIKit

class LoginButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1 / UIScreen.mainScreen().scale
        layer.borderColor = UIColor.darkGrayColor().CGColor
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }

}
