//
//  UITableView+Comet.swift
//  Comet
//
//  Created by Harley.xk on 2018/2/12.
//

import Foundation
import UIKit

extension UITableView {
    
    /// 快速创建可重用的 cell，使用 cell 的类名作为 ReuseIdentifier
    public func dequeueReusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        let identifier = String(describing: Cell.self)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Cell
    }
}
