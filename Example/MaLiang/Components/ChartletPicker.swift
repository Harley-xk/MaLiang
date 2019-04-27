//
//  ChartletPicker.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/26.
//

import UIKit
import MaLiang

open class ChartletPicker: UIViewController {
    
    public struct Options {
        public var itemSize = CGSize(width: 60, height: 60)
        public static var `default` = Options()
    }
    
    public typealias ResultHandler = (MLTexture) -> ()
    
    public static func present(from source: UIViewController, textures: [MLTexture], options: Options = .default, result: ResultHandler?) {
        let picker = ChartletPicker.createInitial(from: UIStoryboard("ChartletPicker"))
        picker.source = source
        picker.textures = textures
        picker.options = options
        picker.resultHandler = result
        picker.modalPresentationStyle = .overCurrentContext
        picker.modalTransitionStyle = .crossDissolve
        source.present(picker, animated: true, completion: nil)
    }

    private weak var source: UIViewController!
    private var textures: [MLTexture]!
    private var options: Options!
    private var resultHandler: ResultHandler?
    
    private var imageCache: ChartletImageCache!
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelAction))
        backgroundView.addGestureRecognizer(tap)
        imageCache = ChartletImageCache(textures: textures)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        runAppearAnimations()
    }

    @objc func cancelAction() {
        runDisappearAnimations { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }

    // MARK: - Animations
    private func runAppearAnimations() {
        let transform = CGAffineTransform(translationX: 0, y: view.bounds.height - collectionView.frame.origin.y + 20)
        collectionView.transform = transform
        UIView.animate(withDuration: 0.2) {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            self.collectionView.transform = .identity
        }
    }
    
    private func runDisappearAnimations(completion: ((Bool) -> Void)? = nil) {
        let endTransform = view.bounds.height - collectionView.frame.origin.y + 20
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.backgroundColor = .clear
            self.collectionView.transform = CGAffineTransform(translationX: 0, y: endTransform)
        }, completion: completion)
    }

}

extension ChartletPicker: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return textures.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartletPickerItemCell", for: indexPath) as! ChartletPickerItemCell
        cell.imageView.loadImage(for: textures[indexPath.item], from: imageCache)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        runDisappearAnimations { (_) in
            self.dismiss(animated: false, completion: {
                self.resultHandler?(self.textures[indexPath.item])
            })
        }
    }
}

class ChartletPickerItemCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
