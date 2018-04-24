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
        brush.color = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)

        brushes = [pen, pencil, brush]
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
    }
    
    @IBAction func clearAction(_ sender: Any) {
        canvas.clear()
    }
    
    
    private func updatePointSize() {
        strokeSizeLabel.text = String(format: "%i", canvas.brush.pointSize)
    }
}

