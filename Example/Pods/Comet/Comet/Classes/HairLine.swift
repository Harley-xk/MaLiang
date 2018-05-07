//
//  HairLine.swift
//  Comet
//
//  Created by Harley.xk on 16/6/28.
//
//

import UIKit

/**
 *  该类用于在视图上添加极细的分割线（粗细<1pt），并可以通过 Autolayout 设置分割线的高度或者宽度
 */
open class HairLine: UIView {

    /**
     *  分割线的粗细属性对应的约束，建议通过 IB 设置
     */
    @IBOutlet var lineConstraint: NSLayoutConstraint?
    
    /**
     *  分割线的实际粗细，建议通过 IB 设置，默认为 0.3
     */
    @IBInspectable var constant: CGFloat = 0.3
    
    override open func layoutSubviews() {
        self.lineConstraint?.constant = self.constant
        super.layoutSubviews()
    }
}
