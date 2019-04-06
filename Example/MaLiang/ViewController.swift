//
//  ViewController.swift
//  MaLiang
//
//  Created by harley-xk on 11/06/2017.
//  Copyright (c) 2017 harley-xk. All rights reserved.
//

import UIKit
import Comet

class ViewController: UIViewController {

    @IBOutlet weak var strokeSizeLabel: UILabel!
    @IBOutlet weak var brushSegement: UISegmentedControl!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    @IBOutlet weak var canvas: Canvas!

    var brushNames = ["Pen", "Pencil", "Brush", "Eraser"]
    var brushes: [Brush] = []
    
    var color: UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    private func registerBrush(with imageName: String) -> Brush {
        let path = Bundle.main.path(forResource: imageName, ofType: "png")!
        return try! canvas.registerBrush(with: URL(fileURLWithPath: path))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let c = Canvas(frame: view.bounds)
//        view.addSubview(c)
//        view.sendSubviewToBack(c)
//        canvas = view as? Canvas
        
        let pen = registerBrush(with: "pen")
        pen.pointSize = 5
        pen.pointStep = 1
        pen.color = color

        let pencil = registerBrush(with: "pencil")
        pencil.pointSize = 3
        pencil.pointStep = 2
        pencil.forceSensitive = 0.3
        pencil.opacity = 0.6
        
        let brush = registerBrush(with: "brush")
        brush.pointSize = 30
        brush.pointStep = 2
        brush.forceSensitive = 0.6
        brush.color = color

//        let eraser = Eraser.global
        
        brushes = [pen, pencil, brush]
        
        brushSegement.removeAllSegments()
        for i in 0 ..< brushes.count {
            let name = brushNames[i]
            brushSegement.insertSegment(withTitle: name, at: i, animated: false)
        }
        brushSegement.selectedSegmentIndex = 0
        styleChanged(brushSegement)
        
        canvas.document?.onElementBegin { doc in
            self.redoButton.isEnabled = false
            }.onElementFinish { doc in
                self.undoButton.isEnabled = true
            }.onRedo { doc in
                self.undoButton.isEnabled = true
                self.redoButton.isEnabled = doc.canRedo
            }.onUndo { doc in
                self.redoButton.isEnabled = true
                self.undoButton.isEnabled = doc.canUndo
        }
    }
    
    @IBAction func changeSizeAction(_ sender: UISlider) {
        let size = Int(sender.value)
        canvas.currentBrush.pointSize = CGFloat(size)
        strokeSizeLabel.text = "\(size)"
    }
    
    @IBAction func styleChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let brush = brushes[index]
        brush.color = color
        brush.use()
        strokeSizeLabel.text = "\(brush.pointSize)"
        sizeSlider.value = Float(brush.pointSize)
    }
    
    @IBAction func undoAction(_ sender: Any) {
        canvas.undo()
    }

    @IBAction func redoAction(_ sender: Any) {
        canvas.redo()
    }

    @IBAction func clearAction(_ sender: Any) {
        canvas.clear()        
    }
    
    @IBAction func snapshotAction(_ sender: Any) {
        let preview = PaintingPreview.createFromStoryboard()
        preview.image = canvas.snapshot()
        navigationController?.push(preview)
    }
    
    // MARK: - color
    @IBOutlet weak var colorSampleView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var rl: UILabel!
    @IBOutlet weak var gl: UILabel!
    @IBOutlet weak var bl: UILabel!
    
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0

    @IBAction func colorChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        let colorv = CGFloat(value) / 255
        switch sender.tag {
        case 0:
            r = colorv
            rl.text = "\(value)"
        case 1:
            g = colorv
            gl.text = "\(value)"
        case 2:
            b = colorv
            bl.text = "\(value)"
        default: break
        }
        
        colorSampleView.backgroundColor = color
        canvas.currentBrush.color = color
    }
}

extension String {
    var floatValue: CGFloat {
        let db = Double(self) ?? 0
        return CGFloat(db)
    }
}

