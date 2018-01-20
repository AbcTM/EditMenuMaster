//
//  ViewController.swift
//  EditMenu
//
//  Created by feng on 2018/1/20.
//  Copyright © 2018年 feng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var showButton: UIButton!
    var viewColor: UIColor = UIColor.white
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    @IBAction func showButtonAction(_ sender: Any) {
        
        let theMenu = UIMenuController.shared
        theMenu.setTargetRect(showButton.frame, in: self.view)
        
        let item = UIMenuItem.init(title: "改变背景", action: #selector(changedBgColor(_:)))
        theMenu.menuItems = [item]
        
        theMenu.setMenuVisible(true, animated: true)
    }
    
    // MARK: - Event
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    /// 这个方法当textView点击也响应，不要惊讶
    /// UIKit框架通过目标操作机制来完成。一个项目的点击导致一个动作消息被发送到响应者链中的第一个对象，该响应者链可以处理该消息。图7-1显示了自定义菜单项（“更改颜色”）的示例。
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        var ret = false
        
        // 如果是自定义按钮事件则表示能响应
        if action == #selector(changedBgColor(_:)) {
            ret = true
        }
        
        return ret
    }
    
    @objc func changedBgColor(_ sender: Any?) {
        
        self.becomeFirstResponder()
        
        if self.viewColor.isEqual(UIColor.white) {
            self.viewColor = UIColor.red
        }else{
            self.viewColor = UIColor.white
        }
        
        self.updateView()
        
        // 避免点击后自动消失
        let theMenu = UIMenuController.shared
        theMenu.isMenuVisible = true
    }
    
    func updateView() {
        showButton.backgroundColor = self.viewColor
    }
    
    // MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

