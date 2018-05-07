//
//  ScrollableSample.swift
//  MaLiang_Example
//
//  Created by Harley.xk on 2018/5/2.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class ScrollableSample: UIViewController {

    @IBOutlet weak var scrollView: ScrollableCanvas!
    @IBOutlet weak var canvas: Canvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.canvas = canvas
        
        DispatchQueue.main.async {
            let pencil = Brush(texture: #imageLiteral(resourceName: "pencil"))
            pencil.pointSize = 5
            pencil.pointStep = 2
            pencil.opacity = 0.6
            pencil.forceSensitive = 0
            self.canvas.brush = pencil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func snapshotAction(_ sender: Any) {
        let preview = PaintingPreview.createFromStoryboard()
        preview.image = canvas.snapshot()
        navigationController?.push(preview)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
