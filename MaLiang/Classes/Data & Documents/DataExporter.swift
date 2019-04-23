//
//  DataExporter.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/23.
//

import Foundation
import CoreGraphics

/// called when saving or reading finished
public typealias ResultHandler = (Result<Void, Error>) -> ()

/// called when saving or reading progress changed
public typealias ProgressHandler = (CGFloat) -> ()

/// class to export canvas data to disk
open class DataExporter {
    
    // MARK: - Saving
    
    /// create documents from specified canvas
    public init(canvas: Canvas) {
        let data = canvas.data
        content = CanvasContent(lineStrips: data?.elements.compactMap { $0 as? LineStrip } ?? [],
                                 chartlets: [])
        textures = canvas.textures
    }
    
    private var content: CanvasContent
    private var textures: [MLTexture]

    /// Save contents to disk
    ///
    /// - Parameters:
    ///   - directory: the folder where to place all datas
    /// - Throws: error while saving
    public func save(to directory: URL, progress: ProgressHandler? = nil, result: ResultHandler? = nil) {
        DispatchQueue(label: "com.maliang.saving").async {
            do {
                try self.saveSynchronously(to: directory, progress: progress)
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
    
    open func saveSynchronously(to directory: URL, progress: ProgressHandler?) throws {
        /// make sure the directory is empty
        let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
        guard contents.count <= 0 else {
            throw MLError.directoryNotEmpty(directory)
        }
        
        // move on progress to 0.01 when passed directory check
        reportProgress(0.01, on: progress)
        
        let encoder = JSONEncoder()
        
        /// save document info
        let info = DocumentInfo.default
        let infoData = try encoder.encode(info)
        try infoData.write(to: directory.appendingPathComponent("info"))
        
        // move on progress to 0.02 when info file saved
        reportProgress(0.02, on: progress)

        /// save vector datas to json file
        let contentData = try JSONEncoder().encode(content)
        try contentData.write(to: directory.appendingPathComponent("content"))
        
        // move on progress to 0.1 when contents file saved
        reportProgress(0.1, on: progress)

        /// save textures to folder
        // only chartlet textures will be saved
//        let texturesForChartlets = content.chartlets.map { $0.texture }
//        let set = Set<MLTexture>(texturesForChartlets)        
//        for i in 0 ..< textures.count {
//            let mlTexture = textures[i]
//            try mlTexture.texture.toData()?.write(to: directory.appendingPathComponent(mlTexture.id.uuidString))
//            
//            // move on progress to 0.1 when contents file saved
//            reportProgress(base: 0.1, unit: i, total: textures.count, on: progress)
//        }
    }
    
    // MARK: - Progress reporting
    /// report progress via progresshander on main queue
    private func reportProgress(_ progress: CGFloat, on handler: ProgressHandler?) {
        DispatchQueue.main.async {
            handler?(progress)
        }
    }
    
    private func reportProgress(base: CGFloat, unit: Int, total: Int, on handler: ProgressHandler?) {
        let progress = CGFloat(unit) / CGFloat(total) * (1 - base) + base
        reportProgress(progress, on: handler)
    }
}
