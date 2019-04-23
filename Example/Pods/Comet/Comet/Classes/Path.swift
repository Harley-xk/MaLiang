//
//  Path.swift
//  Comet
//
//  Created by Harley.xk on 16/6/27.
//
//

import Foundation
import MobileCoreServices

// MARK: - 文件路径，快速获取各种文件路径

open class Path {

    /// 使用路径字符串构建实例
    public init(_ path: String) {
        string = path
    }

    /// 完整路径字符串
    open var string: String
    
    /// URL 实例
    open var url: URL {
        return URL(fileURLWithPath: string)
    }
    
    /// 获取沙盒 Documents 路径
    open class func documents() -> Path {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].path
    }
    
    /// 获取沙盒 Library 路径
    open class func library() -> Path {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0].path
    }
    
    /// 获取沙盒 Cache 路径
    open class func cache() -> Path {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0].path
    }
    
    /// 获取沙盒 Temp 路径
    open class func temp() -> Path {
        return NSTemporaryDirectory().path
    }
    
    /// 获取沙盒 Application Support 路径，不存在时会自动创建
    open class func applicationSupport() -> Path {
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0].path
        if !path.exist {
            path.createDirectory()
        }
        return path
    }
    
    /// 根据名称获取Bundle
    ///
    /// - Parameter name: Bundle 名称，默认为 nil，表示 main bundle
    open class func bundle(_ name: String? = nil) -> Bundle? {
        if name == nil {
            return Bundle.main
        }
        return Bundle(identifier: name!)
    }
    
    
    /// 获取当前目录下的资源文件路径
    ///
    /// - Parameter name: 资源文件名（含扩展名）
    open func resource(_ name: String) -> Path {
        let directory = string as NSString
        return directory.appendingPathComponent(name).path
    }
    
    
    // MARK: - Path Utils
    /// 文件管理器
    open var fileManager: FileManager {
        return FileManager.default
    }
    
    /// 路径是否存在，无论文件或者文件夹
    open var exist: Bool {
        return fileManager.fileExists(atPath: string)
    }
    
    /// 文件是否存在, 返回是否存在，以及是否是文件
    open var fileExist: (exist: Bool, isFile: Bool) {
        var isDirectory = ObjCBool(false)
        let exist = fileManager.fileExists(atPath: string, isDirectory: &isDirectory)
        return (exist, !isDirectory.boolValue)
    }
    
    /// 文件扩展名
    open var pathExtension: String? {
        let path = string as NSString
        return path.pathExtension
    }
    
    /// 创建路径
    open func createDirectory() {
        try? fileManager.createDirectory(atPath: string, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// 获取文件 mime type
    open var mimeType: String? {
        if let ext = pathExtension as NSString? {
            if let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, nil)?.takeUnretainedValue() {
                if let MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType) {
                    let mimeTypeCFString = MIMEType.takeUnretainedValue() as CFString
                    return mimeTypeCFString as String
                }
            }
        }
        return nil
    }
    
    /// 对该目录禁用 iCloud 自动备份
    open func disableAutoBackup() {
        let existInfo = fileExist
        guard existInfo.exist, !existInfo.isFile else {
            return
        }
        var url = self.url
        url.setTemporaryResourceValue(true, forKey: .isExcludedFromBackupKey)
    }
    
    /// 获取文件大小，如果是文件夹，会遍历整个目录及子目录计算所有文件大小
    open var size: UInt64 {
        let fileExist = self.fileExist
        if fileExist.exist {
            if fileExist.isFile {
                return fileSize()
            }else {
                return folderSize()
            }
        }
        return 0
    }
    
    /// 获取文件夹大小，并且格式化为可读字符串
    open var sizeString: String {
        return Path.string(fromBytes: size)
    }
    
    /// 转换字节数为最大单位可读字符串
    open class func string(fromBytes bytes: UInt64) -> String {
        let kb = Double(bytes)/1024;
        if (kb < 1) {
            return "\(bytes)B"
        }
        let mb = kb/1024.0;
        if (mb < 1) {
            return String(format: "%.0fKB", kb)
        }
        let gb = mb/1024.0;
        if (gb < 1) {
            return String(format: "%.1fMB", mb)
        }
        let tb = gb/1024.0;
        if (tb < 1) {
            return String(format: "%.1fG", gb)
        } else {
            return String(format: "%.1fT", tb)
        }
    }
    
    // MARK: - Private
    internal func fileSize() -> UInt64 {
        let fileExist = self.fileExist
        if fileExist.exist && fileExist.isFile {
            if let attributes = try? fileManager.attributesOfItem(atPath: string) as NSDictionary {
                return attributes.fileSize()
            }
        }
        return 0
    }
    
    internal func folderSize() -> UInt64 {
        var folderSize: UInt64 = 0
        
        let fileExist = self.fileExist
        if fileExist.exist && !fileExist.isFile {
            if let contents = try? fileManager.contentsOfDirectory(atPath: string) {
                for file in contents {
                    let path = resource(file)
                    let subFileExist = path.fileExist
                    if subFileExist.exist {
                        if subFileExist.isFile {
                            folderSize += path.fileSize()
                        }else {
                            folderSize += path.folderSize()
                        }
                    }
                }
            }
        }
        return folderSize
    }
}

public extension Bundle
{
    /// 获取应用程序资源包下的路径
    ///
    /// - Parameters:
    ///   - name: 资源名称
    /// - Returns: 返回资源路径
    func resource(_ name: String) -> Path? {
        let path = name as NSString
        let pathExtension = path.pathExtension
        var nameWithoutExtension = name
        if !pathExtension.isEmpty {
            nameWithoutExtension = path.deletingPathExtension
        }
        let string = self.path(forResource: nameWithoutExtension, ofType: pathExtension)
        return string == nil ? nil : Path(string!)
    }
}

public extension String
{
    var path: Path {
        return Path(self)
    }
}


