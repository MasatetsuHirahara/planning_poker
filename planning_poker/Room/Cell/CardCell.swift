//
//  CardCell.swift
//  planning_poker
//
//  Created by 平原　匡哲 on 2020/04/14.
//  Copyright © 2020 平原　匡哲. All rights reserved.
//

import Foundation
import UIKit
class CardCell:UICollectionViewCell{
    // ======== IBOutlet ========
    @IBOutlet weak var mPoint: UILabel!
    @IBOutlet weak var mName: UILabel!
    
    
    // ========  member ========
    var mProperty:CardCellProperty?
    
    // ======== lifeCycle ========
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if mProperty == nil { return }
        
        self.mPoint.text = mProperty!.mPoint
        self.mName.text = mProperty!.mName
    }
    
    // ========
    public func setProperty(_ property:CardCellProperty){
           // メンバー変数に放り込む
           self.mProperty = property
           
           // 画面を再描画する
           self.setNeedsLayout()
       }
}
