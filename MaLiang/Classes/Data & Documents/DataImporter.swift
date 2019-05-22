//
//  DataImporter.swift
//  Chrysan
//
//  Created by Harley-xk on 2019/4/23.
//

import Foundation

/// class for import existing data from saved data
open class DataImporter {
    
    
    /// import existing data from saved file
    ///
    /// - Parameters:
    ///   - directory: directory for saved data contents
    ///   - canvas: canvas to draw data on
    /// - Attention: make sure that all brushes needed are finished seting up before reloading data
    public static func importData(from directory: URL, to canvas: Canvas, progress: ProgressHandler? = nil, result: ResultHandler? = nil) {
        DispatchQueue(label: "com.maliang.importing").async {
            do {
                try self.importDataSynchronously(from: directory, to: canvas, progress: progress)
                DispatchQueue.main.async {
                    result?(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    result?(.failure(error))
                }
            }
        }
    }
    
    public static func importDataSynchronously(from directory: URL, to canvas: Canvas, progress: ProgressHandler? = nil) throws {
        
        let decoder = JSONDecoder()
        
        /// check infomations
        let infoData = try Data(contentsOf: directory.appendingPathComponent("info"))
        let info = try decoder.decode(DocumentInfo.self, from: infoData)
        guard info.library != nil else {
            throw MLError.fileDamaged
        }
        reportProgress(0.02, on: progress)

        /// read contents
        let contentData = try Data(contentsOf: directory.appendingPathComponent("content"))
        let content = try decoder.decode(CanvasContent.self, from: contentData)
        reportProgress(0.1, on: progress)

        do {
            /// read chartlet textures
            let texturePaths = try FileManager.default.contentsOfDirectory(at: directory.appendingPathComponent("textures"), includingPropertiesForKeys: [], options: [])
            reportProgress(0.15, on: progress)
            for i in 0 ..< texturePaths.count {
                let path = texturePaths[i]
                let data = try Data(contentsOf: path)
                try canvas.makeTexture(with: data, id: path.lastPathComponent)
                reportProgress(base: 0.15, unit: i, total: texturePaths.count, on: progress)
            }
        } catch {
            // no textures found
            if info.chartlets > 0 {
                throw MLError.fileDamaged
            }
        }
        
        /// update content size for scrollable canvas
        if let scrollable = canvas as? ScrollableCanvas, let size = content.size {
            scrollable.contentSize = size
        }
        
        /// import elements to canvas
        content.lineStrips.forEach { $0.brush = canvas.findBrushBy(name: $0.brushName) ?? canvas.defaultBrush }
        content.chartlets.forEach { $0.canvas = canvas }
        canvas.data.elements = (content.lineStrips + content.chartlets).sorted(by: { $0.index < $1.index})
        reportProgress(1, on: progress)

        DispatchQueue.main.async {
            /// redraw must be call on main thread
            canvas.redraw()
        }
    }
}
