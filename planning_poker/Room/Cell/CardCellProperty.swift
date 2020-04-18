//
//  CardCellProperty.swift
//  planning_poker
//
//  Created by 平原　匡哲 on 2020/04/14.
//  Copyright © 2020 平原　匡哲. All rights reserved.
//

import Foundation

public class CardCellProperty{
    
    public var mPoint:String = ""
    public var mName:String = ""
    
    init(_ point:String, _ name:String) {
        self.mPoint = point
        self.mName = name
    }
    
}
