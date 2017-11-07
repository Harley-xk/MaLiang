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
        pen.scale = 20
        pen.opacity = 0.8
        canvas.brush = pen

        let pencil = Brush(texture: #imageLiteral(resourceName: "pencil"))
        pencil.scale = 10
        pencil.opacity = 0.1
        
        let brush = Brush(texture: #imageLiteral(resourceName: "brush"))
        brush.scale = 1

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
}

