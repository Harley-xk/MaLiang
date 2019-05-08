//
//  ViewController.swift
//  MaLiang
//
//  Created by Harley-xk on 04/07/2019.
//  Copyright (c) 2019 Harley-xk. All rights reserved.
//

import UIKit
import MaLiang
import Comet
import Chrysan
import Zip

class ViewController: UIViewController {
    
    @IBOutlet weak var strokeSizeLabel: UILabel!
    @IBOutlet weak var brushSegement: UISegmentedControl!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var backgroundSwitchButton: UIButton!
    @IBOutlet weak var backgroundView: UIImageView!
    
    @IBOutlet weak var canvas: ScrollableCanvas!
    
    var filePath: String?
    
    var brushes: [Brush] = []
    var chartlets: [MLTexture] = []
    
    var color: UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    private func registerBrush(with imageName: String) -> Brush {
        do {
            let texture = try canvas.makeTexture(with: UIImage(named: imageName)!.pngData()!)
            return try canvas.registerBrush(name: imageName, textureID: texture.id)
//            return try canvas.registerBrush(name: imageName, from: UIImage(named: imageName)!)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        chartlets = [
            try! canvas.makeTexture(with: UIImage(named: "chartlet-1")!.pngData()!),
            try! canvas.makeTexture(with: UIImage(named: "chartlet-2")!.pngData()!),
            try! canvas.makeTexture(with: UIImage(named: "chartlet-3")!.pngData()!),
        ]
        
        canvas.backgroundColor = .clear
        
        let pen = canvas.defaultBrush!
        pen.name = "Pen"
        pen.opacity = 0.1
        pen.pointSize = 5
        pen.pointStep = 1
        pen.color = color
        
        let pencil = registerBrush(with: "pencil")
        pencil.rotation = .random
        pencil.pointSize = 3
        pencil.pointStep = 2
        pencil.forceSensitive = 0.3
        pencil.opacity = 1
        
        let brush = registerBrush(with: "brush")
        brush.rotation = .ahead
        brush.pointSize = 15
        brush.pointStep = 2
        brush.forceSensitive = 0.6
        brush.color = color
        brush.forceOnTap = 0.5
        
        let texture = try! canvas.makeTexture(with: UIImage(named: "glow")!.pngData()!)
        let glow: GlowingBrush = try! canvas.registerBrush(name: "glow", textureID: texture.id)
        glow.opacity = 0.05
        glow.coreProportion = 0.2
        glow.pointSize = 20
        glow.rotation = .ahead
        
        let claw = registerBrush(with: "claw")
        claw.rotation = .ahead
        claw.pointSize = 30
        claw.pointStep = 5
        claw.forceSensitive = 0.1
        claw.color = color

        
        // make eraser with a texture for pencil
        //        let path = Bundle.main.path(forResource: "pencil", ofType: "png")!
        //        let texture = try? canvas.makeTexture(with: URL(fileURLWithPath: path))
        //        let eraser = Eraser(texture: texture, target: canvas)
        
        /// make eraser with default round point
        let eraser = try! canvas.registerBrush(name: "Eraser") as Eraser
        
        brushes = [pen, pencil, brush, glow, claw, eraser]
        
        brushSegement.removeAllSegments()
        for i in 0 ..< brushes.count {
            let name = brushes[i].name
            brushSegement.insertSegment(withTitle: name, at: i, animated: false)
        }
        brushSegement.selectedSegmentIndex = 0
        styleChanged(brushSegement)
        
        canvas.data.onElementBegin { [unowned self] doc in
            self.redoButton.isEnabled = false
            }.onElementFinish { [unowned self] doc in
                self.undoButton.isEnabled = true
            }.onRedo { [unowned self] doc in
                self.undoButton.isEnabled = true
                self.redoButton.isEnabled = doc.canRedo
            }.onUndo { [unowned self] doc in
                self.redoButton.isEnabled = true
                self.undoButton.isEnabled = doc.canUndo
        }
        
        readDataIfNeeds()
    }
    
    @IBAction func switchBackground(_ sender: UIButton) {
        sender.isSelected.toggle()
        backgroundView.isHidden = !sender.isSelected
    }
    
    @IBAction func changeSizeAction(_ sender: UISlider) {
        let size = Int(sender.value)
        canvas.currentBrush.pointSize = CGFloat(size)
        strokeSizeLabel.text = "\(size)"
    }
    
    @IBAction func styleChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let brush = brushes[index]
        brush.color = color
        brush.use()
        strokeSizeLabel.text = "\(brush.pointSize)"
        sizeSlider.value = Float(brush.pointSize)
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
    
    @IBAction func moreAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Choose Actions", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(title: "Add Chartlet", style: .default) { [unowned self] (_) in
            self.addChartletAction()
        }
        actionSheet.addAction(title: "Snapshot", style: .default) { [unowned self] (_) in
            self.snapshotAction(sender)
        }
        actionSheet.addAction(title: "Save", style: .default) { [unowned self] (_) in
            self.saveData()
        }
        actionSheet.addAction(title: "Cancel", style: .cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func addChartletAction() {
        ChartletPicker.present(from: self, textures: chartlets) { [unowned self] (texture) in
            self.showEditor(for: texture)
//            let x = CGFloat.random(in: 0 ..< self.canvas.bounds.width)
//            let y = CGFloat.random(in: 0 ..< self.canvas.bounds.height)
//            self.canvas.renderChartlet(at: CGPoint(x: x, y: y), size: texture.size, textureID: texture.id)
        }
    }
    
    func showEditor(for texture: MLTexture) {
        ChartletEditor.present(from: self, for: texture) { [unowned self] (editor) in
            let result = editor.convertCoordinate(to: self.canvas)
            self.canvas.renderChartlet(at: result.center, size: result.size, textureID: texture.id, rotation: result.angle)
        }
    }
    
    func snapshotAction(_ sender: Any) {
        let preview = PaintingPreview.create(from: .main)
        preview.image = canvas.snapshot()
        navigationController?.pushViewController(preview, animated: true)
    }
    
    func saveData() {
        self.chrysan.showMessage("Saving...")
        let exporter = DataExporter(canvas: canvas)
        let path = Path.temp().resource(Date().string())
        path.createDirectory()
        exporter.save(to: path.url, progress: { (progress) in
            self.chrysan.show(progress: progress, message: "Saving...")
        }) { (result) in
            if case let .failure(error) = result {
                self.chrysan.hide()
                let alert = UIAlertController(title: "Saving Failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(title: "OK", style: .cancel)
                self.present(alert, animated: true, completion: nil)
            } else {
                let filename = "\(Date().string(format: "yyyyMMddHHmmss")).maliang"
                
                let contents = try! FileManager.default.contentsOfDirectory(at: path.url, includingPropertiesForKeys: [], options: .init(rawValue: 0))
                try? Zip.zipFiles(paths: contents, zipFilePath: Path.documents().resource(filename).url, password: nil, progress: nil)
                try? FileManager.default.removeItem(at: path.url)
                self.chrysan.show(.succeed, message: "Saving Succeed!", hideDelay: 1)
            }
        }
    }
    
    func readDataIfNeeds() {
        guard let file = filePath else {
            return
        }
        chrysan.showMessage("Reading...")

        let path = Path(file)
        let temp = Path.temp().resource("temp.zip")
        let contents = Path.temp().resource("contents")

        do {
            try? FileManager.default.removeItem(at: temp.url)
            try FileManager.default.copyItem(at: path.url, to: temp.url)
            try Zip.unzipFile(temp.url, destination: contents.url, overwrite: true, password: nil)
        } catch {
            let alert = UIAlertController(title: "unzip failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(title: "OK", style: .cancel)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        DataImporter.importData(from: contents.url, to: canvas, progress: { (progress) in
            
        }) { (result) in
            if case let .failure(error) = result {
                self.chrysan.hide()
                let alert = UIAlertController(title: "Reading Failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(title: "OK", style: .cancel)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.chrysan.show(.succeed, message: "Reading Succeed!", hideDelay: 1)
            }

        }
    }
    
    // MARK: - color
    @IBOutlet weak var colorSampleView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var rl: UILabel!
    @IBOutlet weak var gl: UILabel!
    @IBOutlet weak var bl: UILabel!
    
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    
    @IBAction func colorChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        let colorv = CGFloat(value) / 255
        switch sender.tag {
        case 0:
            r = colorv
            rl.text = "\(value)"
        case 1:
            g = colorv
            gl.text = "\(value)"
        case 2:
            b = colorv
            bl.text = "\(value)"
        default: break
        }
        
        colorSampleView.backgroundColor = color
        canvas.currentBrush.color = color
    }
}

extension String {
    var floatValue: CGFloat {
        let db = Double(self) ?? 0
        return CGFloat(db)
    }
}

