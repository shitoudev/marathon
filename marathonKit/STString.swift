//
//  STString.swift
//  marathon
//
//  Created by zhenwen on 9/30/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//

import Foundation

extension String {
    public var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
    public var pathExtension: String {
        
        get {
            return (self as NSString).pathExtension
        }
    }
    public var stringByDeletingLastPathComponent: String {
        
        get {
            return (self as NSString).stringByDeletingLastPathComponent
        }
    }
    public var stringByDeletingPathExtension: String {
        
        get {
            return (self as NSString).stringByDeletingPathExtension
        }
    }
    public var pathComponents: [String] {
        
        get {
            return (self as NSString).pathComponents
        }
    }
    
    public func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    public func stringByAppendingPathExtension(ext: String) -> String? {
        
        let nsSt = self as NSString

        return nsSt.stringByAppendingPathExtension(ext)
    }
}