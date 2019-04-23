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
    /// - Attention: make sure all brush needed are finished seting up before reloading data
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
        
        /// read contents
        let contentData = try Data(contentsOf: directory.appendingPathComponent("content"))
        let content = try decoder.decode(CanvasContent.self, from: contentData)
        
        /// read chartlet textures
        
        content.lineStrips.forEach { $0.brush = canvas.findBrushBy(name: $0.brushName) }
        canvas.data.elements = (content.lineStrips + content.chartlets).sorted(by: { $0.index < $1.index})
        canvas.redraw()
//        <#fields#>
    }
    
}
