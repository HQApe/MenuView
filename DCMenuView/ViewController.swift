//
//  ViewController.swift
//  DCMenuView
//
//  Created by admin on 2018/12/24.
//  Copyright © 2018 ape.zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DCMenuViewDataSource,DCMenuViewDelegate {
    
    var menu : DCMenuView!
    var numbers = 7
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let menu = DCMenuView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 45))
        menu.dataSource = self
        menu.delegate = self
        menu.autoCaculateItemsWidth = true
        view.addSubview(menu)
        self.menu = menu
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        numbers = Int(arc4random()%8)
        self.menu.reloadData()
    }
    
    func numbersOfTitles(in menu: DCMenuView) -> Int {
        return numbers
    }
    
    func menuView(menu: DCMenuView, titleAtIndex index: Int) -> String {
        var title = ""
        
        switch index {
        case 0:
            title = "第一项"
        case 1:
            title = "第二项"
        case 2:
            title = "第三项"
        case 3:
            title = "第四项"
        case 4:
            title = "第五项"
        case 5:
            title = "第六项"
        case 6:
            title = "第七项"
        default:
            title = "NONE"
        }
        return title
    }
    
    func menuView(menu: DCMenuView, shouldSelectedAt index: Int) -> Bool {
        return true
    }
    func menuView(menu: DCMenuView, didSelectedAt index: Int) {
        print(index)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

