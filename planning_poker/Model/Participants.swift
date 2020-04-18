//
//  Participant.swift
//  planning_poker
//
//  Created by 平原　匡哲 on 2020/04/13.
//  Copyright © 2020 平原　匡哲. All rights reserved.
//

import Foundation
import Firebase
public class Participants: NSObject {
    
    enum DataKey:String{
        case Participants = "participants"
    }
    
    public struct Participant: Codable{
        public var id: String = ""
        public var name: String = ""
        public var joinedRoomNos:[Int] = []
        public var points: [Point] = []
        
        init(_ name:String) {
            self.id = NSUUID().uuidString
            self.name = name
        }
        
        // 自身の内容をDicにする
        func convertDic() -> Dictionary<String,Any>?{
            let data = try? JSONEncoder().encode(self)
            if data == nil { return nil }
            
            return Util.convertJsonDataToDic(data!)
        }
        
        func upinsert() -> Bool{
            // strcutをdicに変換
            let dic = self.convertDic()
            if dic == nil { return false }
            
            // firestoreに書き込み
            let db = Firestore.firestore()
            db.collection(DataKey.Participants.rawValue).document(self.id).setData(dic!){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                }else {
                    // 成功時処理
                }
            }
            
            // 本当はwriteを待つ予定だが、非同期なので成功することを信じて成功とみなす
            return true
        }
        
        // roomに参加したことを更新する
        mutating func joinedRoom(_ rn:Int) -> Bool{
            self.joinedRoomNos.append(rn)
            return self.upinsert()
        }
        
        // reqIDに対応するpointを取り出す
        func pickupPoint(_ reqId:String) -> Participants.Point?{
            var ret:Point?
            for p in self.points {
                if p.id == reqId {
                    ret = p
                }
            }
            
            return ret
        }
    }
    public struct Point: Codable{
        public var id: String = ""
        public var score: Int = 0
        
        init(_ id:String, _ score:Int) {
            self.id = id
            self.score = score
        }
    }
    
    // ======== Class Method ========
    public class func createParitipant(_ name:String) -> Participant?{
        
        // struct生成
        let participant = Participant.init(name)
        
        // struct保存
        if !participant.upinsert(){
            return nil
        }
        
        return participant
    }
    
    // 名前で引く
    public class func readParticipantByName(_ name:String, _ completion: @escaping(_ p:Participant?)->Void){
        let db = Firestore.firestore()
        let ref = db.collection(DataKey.Participants.rawValue)
        let query = ref.whereField("name", isEqualTo: name)
        
        query.getDocuments() { (querySnapshot, err) in
            DispatchQueue.main.async {
                if err != nil {
                    // 失敗
                }else{
                    var getParticipant:Participant?
                    for document in querySnapshot!.documents {
                        // 取得内容をstructに変換
                        let jsonData = Util.convertDoucumentDataToJsonData(document.data())
                        if jsonData == nil {
                            return
                        }
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let p = try? decoder.decode(Participant.self, from: jsonData!)
                        if p == nil {
                            // 変換失敗は無理
                            continue
                        }
                        // 同じ名前は認めていないので取れた時点で成功
                        // 配列だけど1つしか要素ないはず
                        getParticipant = p!
                        break
                    }
                    // 取得結果を返す
                    completion(getParticipant)
                    return
                }
            }
        }
    }
    
    // 参加してるRoomNoで引く
    public class func readParticipantByRoomNo(_ rn:Int, _ completion: @escaping(_ p:[Participant])->Void){
        let db = Firestore.firestore()
        let ref = db.collection(DataKey.Participants.rawValue)
        let query = ref.whereField("joinedRoomNos", arrayContains: rn)
        
        query.getDocuments() { (querySnapshot, err) in
            DispatchQueue.main.async {
                if err != nil {
                    // 失敗
                }else{
                    var getParticipant:[Participant] = []
                    for document in querySnapshot!.documents {
                        // 取得内容をstructに変換
                        let jsonData = Util.convertDoucumentDataToJsonData(document.data())
                        if jsonData == nil {
                            return
                        }
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let p = try? decoder.decode(Participant.self, from: jsonData!)
                        if p == nil {
                            // 変換失敗は無理
                            continue
                        }
                        // 同じ名前は認めていないので取れた時点で成功
                        // 配列だけど1つしか要素ないはず
                        getParticipant.append(p!)
                    }
                    // 取得結果を返す
                    completion(getParticipant)
                    return
                }
            }
        }
    }
}
