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

    struct Result {
        var center: CGPoint
        var size: CGSize
    }
    
    typealias ResultHandler = (_ editor: ChartletEditor) -> ()
    
    static func present(from source: UIViewController, for texture: MLTexture, resultHandler: ResultHandler?) {
        let editor = ChartletEditor.createFromStoryboard(UIStoryboard("ChartletPicker"))
        editor.texture = texture
        editor.resultHandler = resultHandler
        editor.modalPresentationStyle = .overCurrentContext
        source.present(editor, animated: false, completion: nil)
    }
    
    func convertCoordinate(to view: UIView) -> Result {
        let center = view.convert(container.center, to: view)
        return Result(center: center, size: imageView.bounds.size)
    }
    
    private var texture: MLTexture!
    private var resultHandler: ResultHandler?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = texture.texture.toUIImage()
        container.frame = .zero
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        container.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        container.addGestureRecognizer(pinch)
        
        container.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scaleContent(to: 1)
        container.center = view.center
    }

    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        resultHandler?(self)
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Gestures
    @IBAction func zoomOutAction(_ sender: Any) {
        let scale = currentScale + 0.1
        scaleContent(to: scale)
        currentScale = scale
    }
    @IBAction func zoomInAction(_ sender: Any) {
        let scale = currentScale - 0.1
        scaleContent(to: scale)
        currentScale = scale
    }
    
    var panOffset = CGPoint.zero
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        if gesture.state == .began {
            panOffset = gesture.location(in: container)
        }
        if gesture.state == .changed {
            container.frame.origin = location - panOffset
        }
    }
    
    private var currentScale: CGFloat = 1
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let scale = currentScale * gesture.scale * gesture.scale
        if gesture.state == .began {
        }
        if gesture.state == .ended {
            scaleContent(to: scale)
            currentScale = scale
        }
        if gesture.state == .changed {
            scaleContent(to: scale)
        }
    }
    
    private func scaleContent(to scale: CGFloat) {
        let scale = scale.valueBetween(min: 0.2, max: 5)
        let center = container.center
        let newSize = texture.size * scale
        container.frame.size = newSize + CGSize(width: 10, height: 10)
        container.center = center
        imageView.frame = CGRect(x: 5, y: 5, width: newSize.width, height: newSize.height)
    }
    
}
