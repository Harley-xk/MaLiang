//
//  MLError.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/23.
//

import Foundation

public enum MLError: Error {
    
    /// the requested file does not exists
    case fileNotExists(String)
    
    /// this image with specified name does not exists
    case imageNotExists(String)
    
    case convertPNGDataFailed
    
    /// file is damaged
    case fileDamaged
    
    /// directory for saving must not have any ohter contents
    case directoryNotEmpty(URL)
    
    /// running MaLiang on a Similator
    case simulatorUnsupported
}
