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
        var angle: CGFloat
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
        let center = imageView.superview!.convert(imageView.center, to: view)
        return Result(center: center, size: imageView.bounds.size, angle: currentAngle)
    }
    
    private var texture: MLTexture!
    private var resultHandler: ResultHandler?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var rotationAnchor: UIImageView!
    
    var imageCenterY: NSLayoutConstraint!
    var imageCenterX: NSLayoutConstraint!
    var imageWidth: NSLayoutConstraint!
    var imageHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.isUserInteractionEnabled = true
        container.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = texture.texture.toUIImage()
        
        imageView.snp.makeConstraints {
            $0.centerX.equalTo(self.view.snp.left)
            $0.centerY.equalTo(self.view.snp.top)
            $0.size.equalTo(60)
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        container.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        container.addGestureRecognizer(pinch)
        
        let rotate = UIPanGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        rotationAnchor.addGestureRecognizer(rotate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scaleContent(to: 1)
        moveContent(to: view.center)
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
            moveContent(to: location - panOffset + imageView.superview!.center)
        }
    }
    
    private var currentScale: CGFloat = 1
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let scale = currentScale * gesture.scale * gesture.scale
        if gesture.state == .ended {
            scaleContent(to: scale)
            currentScale = scale
        }
        if gesture.state == .changed {
            scaleContent(to: scale)
        }
    }
    
    private var currentAngle: CGFloat = 0
    
    @objc private func handleRotationGesture(_ gesture: UIPinchGestureRecognizer) {
        let location = gesture.location(in: view)
        let imageCenter = imageView.superview!.convert(imageView.center, to: view)
        currentAngle =  location.angel(to: imageCenter) - CGFloat.pi / 2
        rotateContent(to: currentAngle)
    }
    
    private func moveContent(to location: CGPoint) {
        imageView.snp.updateConstraints {
            $0.centerX.equalTo(self.view.snp.left).offset(location.x)
            $0.centerY.equalTo(self.view.snp.top).offset(location.y)
        }
    }
    
    private func scaleContent(to scale: CGFloat) {
        let scale = scale.valueBetween(min: 0.2, max: 5)
        let newSize = texture.size * scale
        imageView.snp.updateConstraints {
            $0.width.equalTo(newSize.width)
            $0.height.equalTo(newSize.height)
        }
    }
    
    private func rotateContent(to angle: CGFloat) {
        container.layer.anchorPoint = imageView.superview!.center / container.bounds.size
        container.transform = CGAffineTransform(rotationAngle: -angle)
    }
    
}
