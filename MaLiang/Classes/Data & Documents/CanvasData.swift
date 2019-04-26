//
//  CanvasData.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/22.
//

import Foundation

/// base element that can be draw on canvas
public protocol CanvasElement: Codable {
    
    /// index in the emelent list of canvas
    /// element with smaller index will draw earlier
    /// Automatically set by Canvas.Data
    var index: Int { get set }
    
    /// draw this element on specifyied target
    func drawSelf(on target: RenderTarget)
}

/// clear action, a command to clear the canvas
public struct ClearAction: CanvasElement {
    public var index: Int = 0
    public func drawSelf(on target: RenderTarget) {
        target.clear()
    }
}

/// content data on canvas
open class CanvasData {
    
    /// elements array before an clear action
    open internal(set) var clearedElements: [[CanvasElement]] = []
    
    /// current drawing elements
    open internal(set) var elements: [CanvasElement] = []
    
    /// current unfinished element
    open internal(set) var currentElement: CanvasElement?
    
    /// Append a set of lines to current element in document
    ///
    /// - Parameters:
    ///   - lines: lines to add
    ///   - brush: brush used to draw these lines
    ///   - isNewElement: if sets true, current line strip will be set to finished and a new one will be setup
    open func append(lines: [MLLine], with brush: Brush) {
        guard lines.count > 0 else {
            return
        }
        // append lines to current line strip
        if let lineStrip = currentElement as? LineStrip, lineStrip.brush === brush {
            lineStrip.append(lines: lines)
        } else {
            finishCurrentElement()
            
            let lineStrip = LineStrip(lines: lines, brush: brush)
            currentElement = lineStrip
            undoArray.removeAll()
            h_onElementBegin?(self)
        }
    }
    
    /// add a chartlet to elements
    open func append(chartlet: Chartlet) {
        finishCurrentElement()
        chartlet.index = elementIndex
        elementIndex += 1
        elements.append(chartlet)
        undoArray.removeAll()
        h_onElementFinish?(self)
    }
    
    /// index for latest element
    private var elementIndex: Int = 0
    
    open func finishCurrentElement() {
        guard var element = currentElement else {
            return
        }
        element.index = elementIndex
        elementIndex += 1
        elements.append(element)
        currentElement = nil
        h_onElementFinish?(self)
    }
    
    open func appendClearAction() {
        finishCurrentElement()

        guard elements.count > 0 else {
            return
        }
        clearedElements.append(elements)
        elements.removeAll()
    }
    
    // MARK: - Undo & Redo
    public var canRedo: Bool {
        return undoArray.count > 0
    }
    
    public var canUndo: Bool {
        return elements.count > 0 || clearedElements.count > 0
    }
    
    private(set) var undoArray: [CanvasElement] = []
    
    internal func undo() -> Bool {
        finishCurrentElement()
        
        if let last = elements.last {
            undoArray.append(last)
            elements.removeLast()
        } else if let lastCleared = clearedElements.last {
            undoArray.append(ClearAction())
            elements = lastCleared
            clearedElements.removeLast()
        } else {
            return false
        }
        h_onUndo?(self)
        return true
    }
    
    internal func redo() -> Bool {
        guard currentElement == nil, let last = undoArray.last else {
            return false
        }
        if let _ = last as? ClearAction {
            clearedElements.append(elements)
            elements.removeAll()
        } else {
            elements.append(last)
        }
        undoArray.removeLast()
        h_onRedo?(self)
        return true
    }
    
    // MARK: - EventHandler
    public typealias EventHandler = (CanvasData) -> ()
    
    private var h_onElementBegin: EventHandler?
    private var h_onElementFinish: EventHandler?
    private var h_onRedo: EventHandler?
    private var h_onUndo: EventHandler?
    
    /// this closure will be called when a continuously elements begins
    @discardableResult
    public func onElementBegin(_ h: @escaping EventHandler) -> Self {
        h_onElementBegin = h
        return self
    }
    
    /// this closure will be called when an element finished
    @discardableResult
    public func onElementFinish(_ h: @escaping EventHandler) -> Self {
        h_onElementFinish = h
        return self
    }
    
    /// this closure will be called when a redo command is performed
    @discardableResult
    public func onRedo(_ h: @escaping EventHandler) -> Self {
        h_onRedo = h
        return self
    }
    
    /// this closure will be called when an undo command is performed
    @discardableResult
    public func onUndo(_ h: @escaping EventHandler) -> Self {
        h_onUndo = h
        return self
    }
}
