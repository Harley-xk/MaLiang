//
//  RootViewController.swift
//  MaLiang_Example
//
//  Created by Harley.xk on 2018/5/4.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public extension UIStoryboard {
    
    /// 获取 Main Storyboard
    class var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    /// 根据名称从 MainBundle 中创建 Storyboard
    convenience init(_ name: String) {
        self.init(name: name, bundle: nil)
    }
    
    /// 从 sb 创建视图控制器
    /// identifier 为空时默认使用类名
    func create<T: UIViewController>(identifier: String? = nil) -> T {
        let id = identifier ?? String(describing: T.self)
        return self.instantiateViewController(withIdentifier: id) as! T
    }
}

extension UIViewController {
    
    static func create(from storyboard: UIStoryboard) -> Self {
        return storyboard.create()
    }    
}


class RootViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let vcs = navigationController?.viewControllers, vcs.count == 1 {
            performSegue(withIdentifier: "default", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
