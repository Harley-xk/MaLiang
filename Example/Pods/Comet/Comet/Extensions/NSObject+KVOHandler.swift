//
//  NSObject+KVOHandler.swift
//  Comet
//
//  Created by Harley.xk on 2017/8/18.
//
//

import Foundation

internal class KeyPathObserver: NSObject {
    
    /// 接收属性观察者通知
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath, let handler = handlers[key] {
            handler(object, change, context)
        }
    }
    
    // 根据 keyPath 保存所有的观察者
    fileprivate var handlers: [String: ObserverHandler] = [:]
    
    fileprivate func appendHandler(_ handler: @escaping ObserverHandler, for keyPath: String) {
        handlers[keyPath] = handler
    }
    fileprivate func removeHandler(for keyPath: String) {
        handlers.removeValue(forKey: keyPath)
    }
}

public extension NSObject {
    
    /// KVO 属性观察者回调
    typealias ObserverHandler = (Any?, [NSKeyValueChangeKey : Any]?, UnsafeMutableRawPointer?) -> ()
    
    /// 注册一个闭包形式的属性观察者，每当 keyPath 对应的属性发生变更时，会通过 handler 回调通知
    // 该方法会在 object 内部创建一个私有的 observer 来接收通知，并将其转发到 handler 上
    // 只有在实际注册了 handler 观察者后才会创建 observer，并且此过程是自动的
    func addObserver(for keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer? = nil, handler: @escaping ObserverHandler) {
        if keyPathObserver == nil {
            keyPathObserver = KeyPathObserver()
        }
        keyPathObserver!.appendHandler(handler, for: keyPath)
        addObserver(keyPathObserver!, forKeyPath: keyPath, options: options, context: context)
    }
    
    /// 移除通过 handler 注册的属性观察者
    // 如果不再存在通过 handler 注册的属性观察者，私有的 observer 对象将会被释放
    func removeObserver(for keyPath: String) {
        if keyPathObserver == nil {
            return
        }
        removeObserver(keyPathObserver!, forKeyPath: keyPath)
        keyPathObserver!.removeHandler(for: keyPath)
        if keyPathObserver!.handlers.count <= 0 {
            keyPathObserver = nil
        }
    }
    
    /// Add keyPathObserver property to object whitch is using kvo handlers
    private struct AssociatedKeys {
        static var KeyPathObserverKey = "Comet.KeyPathObserverKey"
    }
    
    /// keyPathObserver is the object whitch acturally received the kvo notifications, and resend it to real object via blocks
    private var keyPathObserver: KeyPathObserver? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.KeyPathObserverKey) as? KeyPathObserver
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.KeyPathObserverKey, newValue as KeyPathObserver?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
