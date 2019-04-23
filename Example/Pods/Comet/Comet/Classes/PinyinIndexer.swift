//
//  PinyinIndexer.swift
//  Comet
//
//  Created by Harley.xk on 16/11/8.
//
//

import UIKit

/// 拼音索引器，将指定的对象数组按照指定属性进行拼音首字母排序并创建索引
@available(*, deprecated, message: "拼音索引器已废除，请使用 `CollectionGrouper` 来实现拼音索引功能")
open class PinyinIndexer<T> {
    
    private var objectList: [T]
    
    /// 处理完毕的对象数组，按索引分组
    open var indexedObjects = [[T]]()
    /// 处理完毕的索引数组（拼音首字母）
    open var indexedTitles = [String]()
    
    /// 创建索引器实例
    ///
    /// - Parameters:
    ///   - objects: 需要索引的对象数组
    ///   - property: 索引依据的属性键值，属性必须为 String 类型
    public init(objects: [T], property: KeyPath<T, String>) {
        objectList = objects
        indexObjects(for: property)
    }
    
    private func indexObjects(for property: KeyPath<T, String>) {
        
        // 按索引分组
        let theCollation = UILocalizedIndexedCollation.current()
        var indexArray = [PinyinIndex<T>]();
        
        for object in self.objectList {
            let index = PinyinIndex(fromObject: object, property: property)
            let section = theCollation.section(for: index, collationStringSelector: #selector(PinyinIndex<T>.pinyin))
            index.sectionNumber = section
            indexArray.append(index)
        }
        
        let sortedIndexArray = indexArray.sorted { (index1, index2) -> Bool in
            return index1.name > index2.name
        }
        
        let sectionCount = theCollation.sectionTitles.count
        
        for i in 0 ..< sectionCount {
            var sectionArray = [T]()
            for j in 0 ..< sortedIndexArray.count {
                let index = sortedIndexArray[j]
                if index.sectionNumber == i {
                    sectionArray.append(index.object)
                }
            }
            if sectionArray.count > 0 {
                indexedObjects.append(sectionArray)
                indexedTitles.append(theCollation.sectionTitles[i])
            }
        }
    }
}

@available(*, deprecated, message: "拼音索引器已废除，请使用 `CollectionGrouper` 来实现拼音索引功能")
class PinyinIndex<T>: NSObject {
    
    var object: T
    var name: String
    var sectionNumber: Int = 0
    
    init(fromObject obj: T, property: KeyPath<T, String>) {
        object = obj
        name = obj[keyPath: property]
    }
    
    @objc func pinyin() -> String {
        return name.pinyin(.firstLetter)
    }
}


