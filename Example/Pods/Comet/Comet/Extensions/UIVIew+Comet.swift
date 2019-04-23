//
//  UIVIew+Comet.swift
//  Comet
//
//  Created by Harley on 2016/11/8.
//
//

import Foundation

public extension UIView {
    /// 快速扩展，获得在 IB 中直接编辑圆角的能力
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    /// 快速扩展，获得在 IB 中直接编辑边框宽度的能力
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    /// 快速扩展，获得在 IB 中直接编辑边框颜色的能力
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
}


public extension Bundle {
    /// 从 xib 文件创建视图
    ///
    /// - Parameters:
    ///   - name: xib 文件名，默认为指定视图类名
    func createView<T: UIView>(_ name: String? = nil, owner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil) -> T {
        let nibName = name ?? T.typeName
        let view = loadNibNamed(nibName, owner: owner, options: options)![0] as! T
        return view
    }
}

public extension UIView {
    /// 从 xib 文件创建视图
    ///
    /// - Parameters:
    ///   - nibName: xib 文件名，默认为指定视图类名
    ///   - bundle: xib 所在的 bundle，默认为 main bundle
    class func createFromXib(_ nibName: String? = nil, owner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil, in bundle: Bundle = Bundle.main) -> Self {
        return bundle.createView(nibName ?? typeName, owner: owner, options: options)
    }
}


public extension UIView {
    
    /// 获取视图快照并转换为图片
    ///
    /// - Attention:
    ///   - 常规截图方式无法截取到特殊层级的图像数据，比如 AVSampleBufferDisplayLayer
    func snapshotImage(afterScreenUpdates: Bool = false) -> UIImage? {
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size: bounds.size).image { (context) in
                drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, true, contentScaleFactor)
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}
