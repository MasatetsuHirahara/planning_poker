//
//  RoomCtrl.swift
//  planning_poker
//
//  Created by 平原　匡哲 on 2020/04/14.
//  Copyright © 2020 平原　匡哲. All rights reserved.
//

import Foundation
import UIKit

// Rooms取得(Appdelegate) → 参加者取得 → View設定 → timerStart
// timer満了 → Rooms取得 → → 参加者取得 → View取得


public class RoomCtrl:UIViewController{
    // ======== IBOutlet ========
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mDescription: UILabel!
    @IBOutlet weak var mChooseNo: UILabel!
    @IBOutlet weak var mTotal: UILabel!
    @IBOutlet weak var mMedian: UILabel!
    @IBOutlet weak var mAvarage: UILabel!
    
    @IBOutlet weak var mRedealButton: UIButton!
    @IBOutlet weak var mOpenButton: UIButton!
    @IBOutlet weak var mDecideButton: UIButton!
    
    // ======== IBAction ========
    @IBAction func mReSelectionTapped(_ sender: Any) {
        NSLog("reselection")
    }
    
    @IBAction func mRedealTapped(_ sender: Any) {
        NSLog("redeal")
    }
    @IBAction func mOpendTapped(_ sender: Any) {
        NSLog("opend")
    }
    @IBAction func mDecideTapped(_ sender: Any) {
        NSLog("decide")
    }
    
    
    // ======== member ========
    var mCardProperty:CardCellProperty?
    var mRoom:Rooms.Room?
    var mMe:Participants.Participant?
    var mParticipants:[Participants.Participant]?
    var mAppDelegate:AppDelegate?
    
    // ======== lifeCycle ========
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // 超絶暫定
        // 表示するroomとmeを取得 取得できなければ死亡
        self.mAppDelegate = UIApplication.shared.delegate as? AppDelegate
        self.mRoom = self.mAppDelegate?.mRoom!
        self.mMe = self.mAppDelegate?.mMe!
        
        // navigationBarを設定
        self.settingNavigation()
        
        // 参加者を取得
        Participants.readParticipantByRoomNo(self.mRoom!.no, self.completionParticipants)
    }
    
    // 参加者の受け取り
    func completionParticipants(_ ps:[Participants.Participant]){
        self.mParticipants = ps
        
        // viewを設定
        self.createViewParam()
    }
    
    // navigation設定
    func settingNavigation() {
        self.navigationItem.title = self.mRoom!.titel
        
        self.navigationController?.navigationBar.barTintColor = UIColor.green
        
        let reqItem = UIBarButtonItem(title: "Req", style: .done, target: self, action: #selector(tappedReq))
        
        self.navigationItem.rightBarButtonItems = [reqItem]
    }
    
    @objc func tappedReq(){
        NSLog("aa")
    }
    // viewを設定
    func createViewParam(){
        // 現在の要件を取り出す
        guard let rm = self.mRoom?.picupCurrentReq() else{ return }
        
        // title
        self.mTitle.text = rm.title
        
        // description
        self.mDescription.text = rm.description
        
        // 各参加者が選択したpointを取得
        var points:[Participants.Point] = []
        for p in self.mParticipants! {
            // 対応するPointを取り出す。　なければ(未選択)なら次
            guard let point = p.pickupPoint(rm.id) else { continue }
            
            points.append(point)
        }
        
        // スコア関連を設定
        self.scoreFieldSetting(rm.isDecide, points)
       
        // 主催者用ボタンを設定
        self.moderatorButtonSetting(self.mRoom!.moderatorId == self.mMe!.id, points)
    }
    
    // 主催者用ボタン設定
    func moderatorButtonSetting(_ isModerator:Bool, _ points:[Participants.Point]) {
        // 表示/非表示切り替え
        self.mRedealButton.isHidden = !isModerator
        self.mOpenButton.isHidden = !isModerator
        self.mDecideButton.isHidden = !isModerator
        
        // 主催者じゃなければ非表示にして終わり
        if !isModerator { return }
        
        // 全員の回答が揃っていれば確定できる
        let isEveryone = (points.count == self.mParticipants!.count)
        self.mDecideButton.isEnabled = isEveryone
        self.mOpenButton.isEnabled = isEveryone
    }
    
    // score関連の設定
    func scoreFieldSetting(_ isDecide:Bool, _ points:[Participants.Point]){
        // Choose
        self.mChooseNo.text = "\(points.count) / \(self.mParticipants!.count)"
        
        // 未決定の場合
        if !isDecide{
            // Choose
            self.mChooseNo.text = "\(points.count) / \(self.mParticipants!.count)"
            
            // Total
            self.mTotal.text = "???"
            
            // Median
            self.mMedian.text = "???"
            
            // Avarage
            self.mAvarage.text = "???"
            
            // cardを設定
            //TODO
            
            return
        }
        
         // Total
         self.mTotal.text = "\(calculateTotal(points))"
        
         // Median
         self.mMedian.text = "\(calculateMedian(points))"
        
         // Avarage
         self.mAvarage.text = "\(calculateAverage(points))"
        
         // cardを設定
         //TODO
        
        
    }
   
    // 合計を計算
    fileprivate func calculateTotal(_ points:[Participants.Point]) -> Int {
        var ret = 0
        for p in points {
            ret += p.score
        }
        return ret
    }
    
    // 中央値を計算 (偶数の場合は大きい方を返す)
    fileprivate func calculateMedian(_ points:[Participants.Point]) -> Int {
        if points.count == 0 { return 0 }
        
        // scoreでソート
        let ps = points.sorted { (p1, p2) -> Bool in
            p1.score > p2.score
        }
        
        // 配列の中央を返す(偶数の場合は大き方で良い)
        return ps[ps.count/2].score
    }
    
    // 平均を計算
    fileprivate func calculateAverage(_ points:[Participants.Point]) -> Int {
        return calculateTotal(points) / 2
    }
}

