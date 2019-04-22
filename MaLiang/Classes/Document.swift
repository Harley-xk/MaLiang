////
////  Document.swift
////  MaLiang
////
////  Created by Harley.xk on 2018/4/24.
////
//
//import Foundation
//import CoreGraphics
//
///// Document only manage the data in memory and temp file path
///// Save the data and read it with your onwn logic
//open class Document {
//    
//    /// all stored actions
//    open internal(set) var elements: [CanvasElement] = []
//    
//    /// current unfinished line strip, will be added into elements once finished
//    open internal(set) var currentLineStrip: MLLineStrip?
//    
//    /// Append a line to current element in document
//    ///
//    /// - Parameters:
//    ///   - newElement: if sets to true, a new element will be created with this line.
//    ///   - texture: texture of this line, if not same to the current element, new element will be created and ignore the value of newElement
//    internal func appendLines(_ lines: [MLLine], with brush: Brush, isNewElement: Bool = false) {
//        
//        /// do noting with empty lines
//        guard lines.count > 0 else {
//            return
//        }
//        
//        if !isNewElement, let lineStrip = currentLineStrip, lineStrip.brush === brush {
//            lineStrip.append(lines: lines)
//        } else {
//            createNewLineStrip(with: lines, brush: brush)
//        }
//    }
//    
//    internal func finishCurrentLineStrip() {
//        if let lineStrip = currentLineStrip {
//            elements.append(.pan(lineStrip))
//            currentLineStrip = nil
//            h_onElementFinish?(self)
//        }
//    }
//    
//    internal func createNewLineStrip(with lines: [MLLine], brush: Brush) {
//        if currentLineStrip != nil {
//            finishCurrentLineStrip()
//        }
//        
//        currentLineStrip = MLLineStrip(lines: lines, brush: brush)
//        undoArray.removeAll()
//        h_onElementBegin?(self)
//    }
//    
//    internal func appendClearAction() {
//        finishCurrentLineStrip()
//        elements.append(.clear)
//        undoArray.removeAll()
//        h_onElementBegin?(self)
//        h_onElementFinish?(self)
//    }
//    
//    // MARK: - Undo & Redo
//    public var canRedo: Bool {
//        return undoArray.count > 0
//    }
//    
//    public var canUndo: Bool {
//        return elements.count > 0
//    }
//    
//    private(set) var undoArray: [CanvasElement] = []
//    
//    internal func undo() -> Bool {
//        finishCurrentLineStrip()
//        guard let last = elements.last else {
//            return false
//        }
//        undoArray.append(last)
//        elements.removeLast()
//        h_onUndo?(self)
//        return true
//    }
//    
//    internal func redo() -> Bool {
//        guard currentLineStrip == nil, let last = undoArray.last else {
//            return false
//        }
//        elements.append(last)
//        undoArray.removeLast()
//        h_onRedo?(self)
//        return true
//    }
//    
//    // MARK: - EventHandler
//    public typealias EventHandler = (Document) -> ()
//    
//    private var h_onElementBegin: EventHandler?
//    private var h_onElementFinish: EventHandler?
//    private var h_onRedo: EventHandler?
//    private var h_onUndo: EventHandler?
//    
//    @discardableResult
//    public func onElementBegin(_ h: @escaping EventHandler) -> Self {
//        h_onElementBegin = h
//        return self
//    }
//    
//    @discardableResult
//    public func onElementFinish(_ h: @escaping EventHandler) -> Self {
//        h_onElementFinish = h
//        return self
//    }
//    
//    @discardableResult
//    public func onRedo(_ h: @escaping EventHandler) -> Self {
//        h_onRedo = h
//        return self
//    }
//    
//    @discardableResult
//    public func onUndo(_ h: @escaping EventHandler) -> Self {
//        h_onUndo = h
//        return self
//    }
//    
//}
