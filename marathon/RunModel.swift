//
//  RunModel.swift
//  marathon
//
//  Created by zhenwen on 9/10/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//

import Foundation
import RealmSwift

class RunModel: Object {
    dynamic var run_id = 0
    dynamic var distance: Double = 0, time = NSDate(), total_time = 0, cal = 0, weight = 0
    let locations = List<LocationModel>()
    
    /**
    主键
    
    - returns: 主键字段
    */
//    override static func primaryKey() -> String {
//        return "run_id"
//    }
    
    /**
    忽略属性列表
    
    - returns: 返回忽略存储的属性列表
    */
//    override static func ignoredProperties() -> [String] {
//        return ["run_id"]
//    }
}