//
//  Dispatch+Comet.swift
//  Pods
//
//  Created by Harley on 2016/12/9.
//
//

import Foundation

extension DispatchQueue {
    
    public func asyncAfter(delay: DispatchTimeInterval, execute work: @escaping @convention(block) () -> Swift.Void) {
        asyncAfter(deadline: .now() + delay, execute: work)
    }
    
    public func asyncAfter(delay seconds: TimeInterval, execute work: @escaping @convention(block) () -> Swift.Void) {
        asyncAfter(deadline: .now() + seconds, execute: work)
    }

    public func asyncAfter(delay: DispatchTimeInterval, execute: DispatchWorkItem) {
        asyncAfter(deadline: .now() + delay, execute: execute)
    }
    
    public func asyncAfter(delay seconds: TimeInterval, execute: DispatchWorkItem) {
        asyncAfter(deadline: .now() + seconds, execute: execute)
    }
}
