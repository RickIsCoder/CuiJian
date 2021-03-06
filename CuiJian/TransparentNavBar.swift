//
//  TransparentNavBar.swift
//  CuiJian
//
//  Created by Rick on 16/1/13.
//  Copyright © 2016年 Rick. All rights reserved.
//

import UIKit

class TransparentNavBar: UINavigationBar {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        self.setBackgroundImage(UIImage(named: "jianbian"), forBarMetrics: UIBarMetrics.Default)
        self.shadowImage = UIImage()
        //self.translucent = true
        
        self.tintColor = UIColor(red: 136/255.0, green: 131/255.0, blue: 109/255.0, alpha: 1)
    }
}
