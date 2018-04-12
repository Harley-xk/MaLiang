//
//  ViewController.swift
//  MaLiang
//
//  Created by harley-xk on 11/06/2017.
//  Copyright (c) 2017 harley-xk. All rights reserved.
//

import UIKit
import MaLiang

class ViewController: UIViewController {

    var canvas: Canvas {
        return view as! Canvas
    }
    
    var brushes: [Brush] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let pen = Brush(texture: #imageLiteral(resourceName: "pen"))
        pen.strokeWidth = 5
        pen.opacity = 1
        pen.strokeStep = 1.5
        canvas.brush = pen

        let pencil = Brush(texture: #imageLiteral(resourceName: "pencil"))
        pencil.strokeWidth = 3
        pencil.opacity = 0.6
        
        let brush = Brush(texture: #imageLiteral(resourceName: "brush"))
        brush.strokeWidth = 30

        brushes = [pen, pencil, brush]
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func styleChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let brush = brushes[index]
        canvas.brush = brush
    }
    
    @IBAction func clearAction(_ sender: Any) {
        canvas.clear()
    }
}

