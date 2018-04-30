//
//  ViewController.swift
//  MaLiang
//
//  Created by harley-xk on 11/06/2017.
//  Copyright (c) 2017 harley-xk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var canvas: Canvas!
    @IBOutlet weak var strokeSizeLabel: UILabel!
    @IBOutlet weak var brushSegement: UISegmentedControl!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    var brushNames = ["Pen", "Pencil", "Brush", "Eraser"]
    var brushes: [Brush] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let pen = Brush(texture: #imageLiteral(resourceName: "pen"))
        pen.pointSize = 5
        pen.pointStep = 1
        pen.color = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        canvas.brush = pen

        let pencil = Brush(texture: #imageLiteral(resourceName: "pencil"))
        pencil.pointSize = 3
        pencil.pointStep = 2
        pencil.opacity = 0.6
        
        let brush = Brush(texture: #imageLiteral(resourceName: "brush"))
        brush.pointSize = 30
        brush.pointStep = 2
        brush.color = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)

        let eraser = Eraser.global
        
        brushes = [pen, pencil, brush, eraser]
        
        brushSegement.removeAllSegments()
        for i in 0 ..< brushes.count {
            let name = brushNames[i]
            brushSegement.insertSegment(withTitle: name, at: i, animated: false)
        }

        do {
            try canvas.setupDocument()
        } catch {
            let alert = UIAlertController(title: "Error!", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeSizeAction(_ sender: UISlider) {
        let size = Int(sender.value)
        canvas.brush.pointSize = CGFloat(size)
        strokeSizeLabel.text = "\(size)"
    }
    
    @IBAction func styleChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let brush = brushes[index]
        canvas.brush = brush
        strokeSizeLabel.text = "\(brush.pointSize)"
        sizeSlider.value = brush.pointSize.float
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
}

