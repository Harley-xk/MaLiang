//
//  Grouper.swift
//  Comet
//
//  Created by Harley-xk on 2019/4/11.
//

import Foundation

/// 集合分组后的数据实体
public class Group<Element, T: Equatable> {
    public var index: T
    public var elements: [Element]
    init(index: T, elements: [Element]) {
        self.index = index
        self.elements = elements
    }
}

/// 集合分组器
open class CollectionGrouper<C: Collection> {
    
    private var collection: C
    
    /// 使用集合实例化分组器
    public init(_ collection: C) {
        self.collection = collection
    }

    /// 对集合按照制定的属性进行分组
    open func grouped<T: Equatable>(by property: KeyPath<C.Element, T>) -> [Group<C.Element, T>] {
        return grouped { $0[keyPath: property] }
    }
    
    /// 通过自定义分组规则进行分组
    /// - rule: 自定义的规则，对每一个 Element 进行计算，返回一个可以判等的数据实体作为分组索引
    open func grouped<T: Equatable>(by rule: (C.Element) -> T) -> [Group<C.Element, T>] {
        var groups: [Group<C.Element, T>] = []
        collection.forEach { (element) in
            let index = rule(element)
            if let group = groups.first(where: { (g) -> Bool in
                g.index == index
            }) {
                group.elements.append(element)
            } else {
                let group = Group(index: index, elements: [element])
                groups.append(group)
            }
        }
        return groups
    }
}

public extension Array {
    
    func grouped<T: Equatable>(by property: KeyPath<Element, T>) -> [Group<Element, T>] {
        return CollectionGrouper(self).grouped(by: property)
    }
    
    func grouped<T: Equatable>(by rule: (Element) -> T) -> [Group<Element, T>] {
        return CollectionGrouper(self).grouped(by: rule)
    }
}
