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
        pen.strokeWidth = 5
        pen.strokeStep = 1
        pen.opacity = 1
        pen.color = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        canvas.brush = pen

        let pencil = Brush(texture: #imageLiteral(resourceName: "pencil"))
        pencil.strokeWidth = 3
        pencil.strokeStep = 2
        pencil.opacity = 0.6
        
        let brush = Brush(texture: #imageLiteral(resourceName: "brush"))
        brush.strokeWidth = 30
        brush.strokeStep = 2
        brush.color = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)

        brushes = [pen, pencil, brush]
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeSizeAction(_ sender: UISlider) {
        let size = sender.value
        canvas.brush.strokeWidth = CGFloat(size)
        strokeSizeLabel.text = "\(size)"
    }
    
    @IBAction func styleChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let brush = brushes[index]
        canvas.brush = brush
        strokeSizeLabel.text = "\(brush.strokeWidth)"
    }
    
    @IBAction func clearAction(_ sender: Any) {
        canvas.clear()
    }
}

