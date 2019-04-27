//
//  ChartletEditable.swift
//  MaLiang_Example
//
//  Created by Harley-xk on 2019/4/27.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import MaLiang
import SnapKit

class ChartletEditor: UIViewController {

    static func present(from source: UIViewController, for texture: MLTexture) {
        let editor = ChartletEditor()
        editor.texture = texture
        editor.modalPresentationStyle = .overCurrentContext
        source.present(editor, animated: false, completion: nil)
    }
    
    private var texture: MLTexture!
    private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(image: texture.texture.toUIImage())
        view.addSubview(imageView)
        imageView.frame = CGRect(origin: CGPoint(x: view.center.x - texture.size.width / 2,
                                                 y: view.center.y - texture.size.height / 2),
                                 size: texture.size)
        self.imageView = imageView
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePangesture(_:)))
        imageView.addGestureRecognizer(pan)
        imageView.isUserInteractionEnabled = true
    }
    
     @objc private func handlePangesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        imageView.center = location
    }
    
}
