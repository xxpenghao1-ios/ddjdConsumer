//
//  Array.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/1.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
extension Array {
    // 数组去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}
