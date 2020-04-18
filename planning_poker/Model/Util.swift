//
//  Util.swift
//  Model
//
//  Created by 平原　匡哲 on 2020/04/12.
//  Copyright © 2020 平原　匡哲. All rights reserved.
//

import Foundation


public class Util{
    class func convertDoucumentDataToJsonData(_ input:Dictionary<String, Any>?) -> Data?{
        if input == nil { return nil }
        
        let jsonObj = try? JSONSerialization.data(withJSONObject: input!, options:JSONSerialization.WritingOptions.prettyPrinted)
        if jsonObj == nil { return  nil }
        
        let jsonStr = String(data: jsonObj!, encoding: .utf8)
        if jsonStr == nil { return nil }
        
        return jsonStr!.data(using: .utf8)
    }
    
    class func convertJsonDataToDic(_ input: Data?) -> Dictionary<String, Any>?{
        if input == nil { return nil }
        
        return  try? JSONSerialization.jsonObject(with:input!, options: []) as? Dictionary<String,Any>
    }
}
