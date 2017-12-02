//
//  DownloadAssetsNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/9.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya

fileprivate let assetDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()
///资源下载
public enum Asset:TargetType{
    public var headers: [String : String]? {
        return nil
    }
    
    case currentImage6
    public var baseURL: URL {
        return URL(string:"http://www.cxh777.com")!
    }
    var assetName: String {
        switch self {
        case .currentImage6: return "currentImage6.png"
        }
    }
    
    public var path: String {
        return "/front/static/img/uploadsheadportrait/" + assetName
    }
    
    var localLocation: URL {
        return assetDir.appendingPathComponent(assetName)
    }
    
    var downloadDestination: DownloadDestination {
        return { _, _ in return (self.localLocation, .removePreviousFile) }
    }
    
    public var task: Task {
        return .downloadDestination(downloadDestination)
    }
    ///请求方式
    public var method:Moya.Method{
        return .get
    }
    ///请求参数
    public var parameters: [String:Any]? {
        return  nil
    }
    ///参数编码
    public var parameterEncoding:ParameterEncoding{
        return JSONEncoding.default
        
    }
    //单元测试用
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
}
