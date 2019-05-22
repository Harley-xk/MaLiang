//
//  ChartletImageCache.swift
//  MaLiang_Example
//
//  Created by Harley-xk on 2019/4/27.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import MaLiang

class ChartletImageCache {
    
    init(textures: [MLTexture]) {
        self.textures = textures
        imageCache = [:]
    }
    
    private var textures: [MLTexture]
    private var imageCache: [String: UIImage]
    
    func retriveImage(for id: String) -> UIImage? {
        if let image = imageCache[id] {
            return image
        }
        else if let image = findTexture(by: id)?.texture.toUIImage() {
            imageCache[id] = image
            return image
        } else {
            return nil
        }
    }
    
    func retriveImage(for mlTexture: MLTexture) -> UIImage? {
        if let image = imageCache[mlTexture.id] {
            return image
        }
        else if let image = mlTexture.texture.toUIImage() {
            imageCache[mlTexture.id] = image
            return image
        } else {
            return nil
        }
    }
    
    private func findTexture(by id: String) -> MLTexture? {
        return textures.first { $0.id == id }
    }
}

extension UIImageView {
    func loadImage(by id: String, from cache: ChartletImageCache) {
        image = cache.retriveImage(for: id)
    }
    
    func loadImage(for texture: MLTexture, from cache: ChartletImageCache) {
        image = cache.retriveImage(for: texture)
    }

}
