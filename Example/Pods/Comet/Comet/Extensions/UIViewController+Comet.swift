//
//  UIViewController+Comet.wwift
//  Comet
//
//  Created by Harley on 2016/11/8.
//
//

import Foundation
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
        let id = identifier ?? T.typeName
        return self.instantiateViewController(withIdentifier: id) as! T
    }
    
    /// 创建当前 sb 入口视图控制器的实例
    func createInitial<T: UIViewController>() -> T {
        return instantiateInitialViewController() as! T
    }
    
    /// 创建当前 sb 入口视图控制器的实例
    @available(*, deprecated, message: "请使用 createInitial 方法以获得类型转换及错误检查支持支持。")
    var initial: UIViewController? {
        return instantiateInitialViewController()
    }
}

public extension UIViewController {
    
    /// 从 Storyboard 实例化视图控制器
    ///
    /// - Parameters:
    ///   - name: Storyboard 名称，不传默认为Main
    ///   - bunlde: Storyboard 所在的 Bundle 不传默认为 main bundle
    ///   - id: 视图控制器在 Storyboard 中的id，不传默认为类名
    @available(*, deprecated, message: "请避免使用 String 来指定 Stroyboard，建议通过扩展 UIStoryboard 来获得代码高亮和语法检查支持，请使用 createFromStoryboard 方法。")
    class func fromSB(_ name: String? = nil, bunlde: Bundle? = nil, id: String? = nil) -> Self {
        let bundle = bunlde ?? Bundle.main
        let sbName = name ?? "Main"
        let sb = UIStoryboard(name: sbName, bundle: bundle)
        let identifier = id ?? typeName
        return sb.create(identifier: identifier)
    }
    
    /// 从 Storyboard 实例化视图控制器
    ///
    /// - Parameters:
    ///   - storyboard: 视图控制器所在的故事版，默认为 main
    ///   - identifier: 视图控制器在 Storyboard 中的 identifier，不传默认为类名
    /// - Description:
    ///   建议对 UIStoryboard 扩展来获得常用的故事版对象，参见 UIStoryboard.main 的实现
    class func createFromStoryboard(_ storyboard: UIStoryboard = .main, identifier: String? = nil) -> Self {
        return storyboard.create(identifier: identifier ?? typeName)
    }
    
    /// 从 Storyboard 实例化入口视图控制器
    ///
    /// - Parameters:
    ///   - storyboard: 视图控制器所在的故事版，默认为 main
    class func createInitial(from storyboard: UIStoryboard = .main) -> Self {
        return storyboard.createInitial()
    }
}


public extension UIViewController {
    
    @available(*, unavailable, renamed: "createFrom")
    class func fromXib(_ nibName: String? = nil, bundle: Bundle? = nil) -> Self {
        let name = nibName ?? typeName
        return self.init(nibName: name, bundle: bundle)
    }
    
    /// 从 Xib 文件创建视图控制器，nibName 为空时默认使用类名
    class func createFromXib(_ nibName: String? = nil, bundle: Bundle? = nil) -> Self {
        let name = nibName ?? typeName
        return self.init(nibName: name, bundle: bundle)
    }
}

public extension UIViewController {

    /**
     *  设置当前视图的导航条返回按钮标题
     *  @attention 只有使用默认返回按钮时有效
     */
    var navigationBackTitle: String? {
        get {
            if let previous = self.previousNavigationContent {
                return previous.navigationItem.backBarButtonItem?.title
            }
            return nil
        }
        set {
            if let previous = self.previousNavigationContent {
                previous.navigationItem.backBarButtonItem = UIBarButtonItem(title: newValue, style: .plain, target: nil, action: nil)
            }
        }
    }
    
    /// 获取导航控制器栈中前一个视图控制器，不存在时返回空
    var previousNavigationContent: UIViewController? {
        if let viewControllers = self.navigationController?.viewControllers,
            viewControllers.count >= 2 {
            let index = viewControllers.count - 2
            return viewControllers[index]
        }
        return nil
    }
    
    /**
     *  设置导航控制器栈中下一个视图的返回按钮标题
     *  @attention 不会改变当前返回按钮的标题
     */
    var nextNavigationBackTitle: String? {
        get {
            return self.navigationItem.backBarButtonItem?.title
        }
        set {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: newValue, style: .plain, target: nil, action: nil)
        }
    }
}

public extension NSObject {
    /// 获取类名，不包含完整的模块名称
    class var typeName: String {
        return String(describing: self)
    }
}

