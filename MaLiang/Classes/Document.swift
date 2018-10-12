//
//  Document.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/24.
//

import Foundation
import CoreGraphics

/// Element 由多个 MLLine 组成，MLLine 是画布绘制的基本单位
open class CanvasElement: Codable {
    /// 纹理文件名称，同一个 Element 只能使用同一个纹理
    var textureName: String?
    
    /// 纹理在 OPENGL 中的 id，0 表示纹理还未创建
    var textureId: UInt32 = 0
    
    /// 保存纹理的尺寸，以便从缓存的纹理文件重新创建时能正确设置
    var t_w: Int = 0
    var t_h: Int = 0
    
    /// line 应该至少有一个，不包含 line 的 Element 会被丢弃
    var lines: [MLLine] = []
    
    func pushLines(_ lines: [MLLine]) {
        self.lines.append(contentsOf: lines)
    }
}

public struct CanvasAction: Codable {
    
    enum ActionType: String, Codable {
        case painting = "paint"
        case clear = "clear"
    }
    
    var actionType: ActionType = .painting
    var element: CanvasElement?
}

/// Document only manage the data in memory and temp file path
/// Save the data and read it with your onwn logic
open class Document {
    
    /// all stored actions
    open var actions: [CanvasAction] = []
    
    /// current unfinished element, will be added into elements once finished
    open var currentElement: CanvasElement?
    
    /// get the element id of element, create if not exists
    @discardableResult
    open func createTexture(for element: CanvasElement) -> MLTexture? {
        guard let name = element.textureName else {
            return nil
        }
        
        let path = self.texturePath.appendingPathComponent(name)
        if let data = try? Data(contentsOf: path) {
            let bytes = data.withUnsafeBytes {
                [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
            }
            let texture = MLTexture(width: element.t_w, height: element.t_w, data: bytes)
            texture.createGLTexture()
            element.textureId = texture.gl_id
            return texture
        }
        return nil
    }
    
    /// a path to place elements、textures and any other datas
    public private(set) var tempPath: URL
    public private(set) var texturePath: URL

    /// create an empty document, Set up cache directory
    init() throws {
        let name = Date().timeIntervalSince1970
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        self.tempPath = url.appendingPathComponent(".ml.temp.\(name)")
        self.texturePath = tempPath.appendingPathComponent("texture", isDirectory: true)
        try FileManager.default.createDirectory(at: texturePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// Append a line to current element in document
    ///
    /// - Parameters:
    ///   - newElement: if sets to true, a new element will be created with this line.
    ///   - texture: texture of this line, if not same to the current element, new element will be created and ignore the value of newElement
    open func appendLines(_ lines: [MLLine], with texture: MLTexture, newElement: Bool = false) {
        
        /// do noting with empty lines
        guard lines.count > 0 else {
            return
        }
        
        let textureName = String(texture.gl_id)
        if !newElement, let element = currentElement, textureName == element.textureName {
            element.pushLines(lines)
        } else {
            createNewElementWith(lines: lines, texture: texture)
        }
    }
    
    open func finishCurrentElement() {
        if let element = currentElement {
            let action = CanvasAction(actionType: .painting, element: element)
            actions.append(action)
            currentElement = nil
            h_onElementFinish?(self)
        }
    }
    
    private func createNewElementWith(lines: [MLLine], texture: MLTexture) {
        if currentElement != nil {
            finishCurrentElement()
        }

        let name = String(texture.gl_id)
        let element = CanvasElement()
        element.textureId = texture.gl_id
        element.textureName = name
        element.t_w = texture.gl_width
        element.t_h = texture.gl_height
        element.pushLines(lines)
        currentElement = element
        
        save(texture: texture, name: name)
        
        undoActions.removeAll()
        h_onElementBegin?(self)
    }
    
    /// saving texture in a background thread
    private func save(texture: MLTexture, name: String) {
        DispatchQueue.global().async {
            let path = self.texturePath.appendingPathComponent(name)
            let data = Data(bytes: texture.gl_data)
            try? data.write(to: path)
        }
    }
    
    open func appendClearAction() {
        let action = CanvasAction(actionType: .clear, element: nil)
        actions.append(action)
        undoActions.removeAll()
    }
    
    // MARK: - Undo & Redo
    /// Notice: Do not call these two function directly, they will be called by Canvas
    public var canRedo: Bool {
        return undoActions.count > 0
    }
    
    public var canUndo: Bool {
        return actions.count > 0
    }
    
    private(set) var undoActions: [CanvasAction] = []

    func undo() -> Bool {
        if let current = currentElement {
            let action = CanvasAction(actionType: .painting, element: current)
            undoActions.append(action)
            currentElement = nil
        } else if actions.count > 0 {
            undoActions.append(actions.last!)
            actions.removeLast()
        } else {
            return false
        }
        h_onUndo?(self)
        return true
    }
    
    func redo() -> Bool {
        guard currentElement == nil, undoActions.count > 0 else {
            return false
        }
        actions.append(undoActions.last!)
        undoActions.removeLast()
        h_onRedo?(self)
        return true
    }
    
    // MARK: - EventHandler
    public typealias EventHandler = (Document) -> ()
    
    private var h_onElementBegin: EventHandler?
    private var h_onElementFinish: EventHandler?
    private var h_onRedo: EventHandler?
    private var h_onUndo: EventHandler?
    
    @discardableResult
    public func onElementBegin(_ h: @escaping EventHandler) -> Self {
        h_onElementBegin = h
        return self
    }
    
    @discardableResult
    public func onElementFinish(_ h: @escaping EventHandler) -> Self {
        h_onElementFinish = h
        return self
    }
    
    @discardableResult
    public func onRedo(_ h: @escaping EventHandler) -> Self {
        h_onRedo = h
        return self
    }
    
    @discardableResult
    public func onUndo(_ h: @escaping EventHandler) -> Self {
        h_onUndo = h
        return self
    }
    
}
