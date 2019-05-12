//
//  ScrollingViewController.swift
//  MaLiang_Example
//
//  Created by Harley-xk on 2019/4/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import MaLiang

class ScrollingViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvas: Canvas!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        
        let brush = registerBrush(with: "pencil")
        brush?.pointSize = 8
        brush?.pointStep = 1
        brush?.forceSensitive = 0.2
        brush?.color = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        brush?.use()
    }
    
    private func registerBrush(with imageName: String) -> Brush? {
        let path = Bundle.main.path(forResource: imageName, ofType: "png")!
        return try? canvas.registerBrush(from: URL(fileURLWithPath: path))
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
