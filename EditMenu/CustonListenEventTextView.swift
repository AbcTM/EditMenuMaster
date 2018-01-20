//
//  CustonListenEventTextView.swift
//  EditMenu
//
//  Created by feng on 2018/1/20.
//  Copyright © 2018年 feng. All rights reserved.
//

import UIKit

class CustonListenEventTextView: UITextView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    // 
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print("action:\(action.description), sender:\(sender.debugDescription)")
        return super.canPerformAction(action, withSender: sender)
    }

}
