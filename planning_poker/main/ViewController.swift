//
//  ViewController.swift
//  planning_poker
//
//  Created by 平原　匡哲 on 2020/04/11.
//  Copyright © 2020 平原　匡哲. All rights reserved.
//

import UIKit

import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var mInputField: UITextField!
    
    // Startボタンタップ
    @IBAction func startTapped(_ sender: Any) {
        if mInputField.text == nil || mInputField.text! == ""{
            return
        }
        
        // 入力された名前で引く
        Participants.readParticipantByName(mInputField.text!,completionParticipant)
    }
    
    // participant受け取りメソッド
    func completionParticipant (_ p:Participants.Participant?)->Void{
        
        // particpant
        var participant = p
        if p == nil {
            participant = Participants.createParitipant(mInputField.text!)
        }
        
        // userを保存
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mMe = participant!
        
        self.goStart()
    }
    
    // start画面に遷移
    func goStart(){
        // Start画面へ遷移
        let sb:UIStoryboard = UIStoryboard.init(name: Const.storyBorderID.StartCtrl.rawValue, bundle: Bundle.init(for: StartCtrl.self))
        let viewCtrl = sb.instantiateViewController(withIdentifier: Const.storyBorderID.StartCtrl.rawValue) as! StartCtrl
        viewCtrl.modalPresentationStyle = .fullScreen
        self.present(viewCtrl, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

