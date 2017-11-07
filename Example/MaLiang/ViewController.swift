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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let canvas = view as? Canvas {
            canvas.brushColor = UIColor.red
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

