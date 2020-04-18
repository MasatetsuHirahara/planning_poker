//
//  Start.swift
//  planning_poker
//
//  Created by 平原　匡哲 on 2020/04/15.
//  Copyright © 2020 平原　匡哲. All rights reserved.
//

import Foundation
import UIKit

class StartCtrl:UIViewController{
    
    // ======== IBOutlet ========
    @IBOutlet weak var mRoomNoField: UITextField!
    @IBOutlet weak var mRoomTitle: UITextField!
    
    // ======== IBAction ========
    @IBAction func tappedCreate(_ sender: Any) {
        // 入力なしはスルー
        if mRoomTitle.text == nil || mRoomTitle.text == "" {
            return
        }
        
        // roomNoを作る
        Rooms.createRoomNo(self.completionRoomNo)
    }
    
    // ======== member ========
    var mRoomNo:Rooms.RoomNo?
    
    
    
    //  ======== lifeCycle ========
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // ======== ========
    // roomNo受け取り
    func completionRoomNo(_ rn:Rooms.RoomNo?) {
        // 取得失敗はスルー
        if rn == nil { return }
        var roomNo = rn!
        
        // 使用するNoは取得した内容から更新したもの
        roomNo.increment()
        // roomNoを更新しておく 更新失敗は失敗
        if !roomNo.update(){
            return
        }
        self.mRoomNo = roomNo
        
        // roomを作る
        createRoom()
    }
    
    // room作る
    func createRoom(){
        if self.mRoomNo == nil { return }
        
        // roomを作る 失敗は終了
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let r = Rooms.createRoom(self.mRoomNo!.no, mRoomTitle.text!, appDelegate.mMe!.id)
        if r == nil { return }
        appDelegate.mRoom = r!
        
        // roomを作ったので、participantを更新
        _ = appDelegate.mMe!.joinedRoom(r!.no)
        
        // room画面へ遷移
        self.goRoom()
    }
    
    // roomに遷移
    func goRoom(){
        // Room画面へ遷移
        let sb:UIStoryboard = UIStoryboard.init(name: Const.storyBorderID.RoomCtrl.rawValue, bundle: Bundle.init(for: RoomCtrl.self))
        let viewCtrl = sb.instantiateViewController(withIdentifier: Const.storyBorderID.RoomCtrl.rawValue) as! RoomCtrl
        viewCtrl.modalPresentationStyle = .fullScreen
        let naviCtrl = UINavigationController(rootViewController: viewCtrl)
        self.present(naviCtrl, animated: true, completion: nil)
    }
    
}
