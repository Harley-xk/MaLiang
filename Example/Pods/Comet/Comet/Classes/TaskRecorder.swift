//
//  TaskRecorder.swift
//  Comet
//
//  Created by Harley.xk on 16/6/27.
//
//


import UIKit

public protocol TaskProtocol: AnyObject {
    func cancel()
}

/**
 用于记录发起的任务（比如网络请求），如果在对象被销毁时任务还未执行完毕，这些任务将被取消并销毁
 */
class TaskRecorder {

    var unfinishedTasks = NSHashTable<AnyObject>.weakObjects()
    
    func add(task: TaskProtocol) {
        self.unfinishedTasks.add(task)
    }
    
    private func cancelUnfinishedTasks() {
        if let tasks = self.unfinishedTasks.objectEnumerator().allObjects as? [TaskProtocol] {
            for task in tasks {
                task.cancel()
            }
        }
    }
    
    deinit {
        self.cancelUnfinishedTasks()
    }
}

public extension NSObject {
    // MARK: - TaskRecoder
    
    /// 记录发起的任务，自动创建任务记录器
    /// 会在对象销毁时取消并清空所有已记录且尚未执行完毕的任务
    func record(task: TaskProtocol) {
        
        if self.taskRecorder == nil {
            self.taskRecorder = TaskRecorder()
        }
        self.taskRecorder!.add(task: task)
    }
    
    private struct AssociatedKeys {
        static var TaskRecorderKey = "Comet.TaskRecorderKey"
    }
    
    private var taskRecorder: TaskRecorder? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.TaskRecorderKey) as? TaskRecorder
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.TaskRecorderKey, newValue as TaskRecorder?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
