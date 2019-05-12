//
//  TextureElementSamples.swift
//  MaLiang_Example
//
//  Created by Harley-xk on 2019/4/26.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import MaLiang

struct Chartlet {
    var texture_id: UUID
    var size: CGSize
}

class TextureElementSamples: UIViewController {

    @IBOutlet weak var canvas: Canvas!
    @IBOutlet weak var segement: UISegmentedControl!
    
    var chartlets: [MLTexture] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chartlets = ["chartlet-1", "chartlet-2", "chartlet-3"].compactMap({ (name) -> MLTexture? in
            return try? canvas.makeTexture(with: UIImage(named: name)!.pngData()!)
        })
        
        canvas.defaultBrush.pointSize = 20
        
        canvas.tapGesture?.isEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tap)
    }
    

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        
        guard gesture.state == .ended, chartlets.count >= segement.numberOfSegments else {
            return
        }
        
        let chartlet = chartlets[segement.selectedSegmentIndex]
                
        let location = gesture.location(in: canvas)
        canvas.renderChartlet(at: location, size: chartlet.size, textureID: chartlet.id)
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
