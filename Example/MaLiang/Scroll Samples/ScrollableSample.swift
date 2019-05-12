//
//  ScrollableSample.swift
//  MaLiang_Example
//
//  Created by Harley.xk on 2018/5/2.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import MaLiang

class ScrollableSample: UIViewController {

    @IBOutlet weak var canvas: ScrollableCanvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.backgroundColor = .clear
        canvas.contentSize = CGSize(width: 1024, height: 1024)
        
        let path = Bundle.main.path(forResource: "pencil", ofType: "png")!
        let pencil = try? self.canvas.registerBrush(from: URL(fileURLWithPath: path))
        pencil?.pointSize = 5
        pencil?.pointStep = 2
        pencil?.opacity = 0.6
        pencil?.forceSensitive = 0
        pencil?.use()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func snapshotAction(_ sender: Any) {
        let preview = PaintingPreview.create(from: .main)
        preview.image = canvas.snapshot()
        navigationController?.pushViewController(preview, animated: true)
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
