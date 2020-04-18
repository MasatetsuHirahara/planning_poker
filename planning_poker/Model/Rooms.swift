//
//  Room.swift
//  Model
//
//  Created by 平原　匡哲 on 2020/04/12.
//  Copyright © 2020 平原　匡哲. All rights reserved.
//

import Foundation
import Firebase
public class Rooms: NSObject {
    
    static let roomNoInitialValue:Int = 1000
    
    enum DataKey:String{
        case rooms = "rooms"
        case requrements = "requrements"
        case requrement = "requrement"
        case roomNo = "room_no"
    }
    
    public struct Room: Codable{
        public var id: String = ""
        public var no: Int = 0
        public var titel: String = ""
        public var requirements: [Requirement] = []
        public var participants: [String] = []
        public var currentReqId:String = ""
        public var moderatorId:String = ""

        init(_ no:Int, _ title:String, _ pid:String) {
            self.id = NSUUID().uuidString
            self.no = no
            self.titel = title
            self.participants = [pid]
            self.moderatorId = pid
        }

        // 自身の内容をDicにする
        func convertDic() -> Dictionary<String,Any>?{
            let data = try? JSONEncoder().encode(self)
            if data == nil { return nil }
            
            return Util.convertJsonDataToDic(data!)
        }
        func create() -> Bool{
            // strcutをdicに変換
            let dic = self.convertDic()
            if dic == nil { return false }
            
            // firestoreに書き込み
            let db = Firestore.firestore()
            db.collection(DataKey.rooms.rawValue).document(self.id).setData(dic!){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                   // 成功処理
                }
            }
            return true
        }
        
        // 保持している要件配列からcurrentIDに該当する物を取り出す
        func picupCurrentReq()->Requirement?{
            var ret:Requirement?
            // 保持している要件配列を走査
            for req in self.requirements {
                if req.id == self.currentReqId{
                    ret = req
                    break
                }
            }
            return ret
        }
    }
    
    public struct Requirement: Codable {
        public var id: String = ""
        public var title: String = ""
        public var description: String = ""
        public var isDecide:Bool = false
    }
    
    public struct RoomNo:Codable {
        public var no:Int = roomNoInitialValue

        mutating func increment(){
            self.no += 1
        }

        init?(){
            var no:Int?
            let db = Firestore.firestore()
            let rnRef = db.collection(DataKey.rooms.rawValue).document(DataKey.roomNo.rawValue)
            rnRef.getDocument { (document,err) in
                if let document = document, document.exists {
                    // 取得内容をstructに変換
                    let jsonData = Util.convertDoucumentDataToJsonData(document.data())
                    if jsonData == nil {
                        return
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let rn = try? decoder.decode(RoomNo.self, from: jsonData!)
                    if rn == nil {
                        return
                    }
                    // 成功!
                    no = rn!.no
                } else {
                    // 読み込み失敗
                    return
                }
            }
            // 取得した内容書き込み
            self.no = no!
        }

        // 自身の内容をDicにする
        func convertDic() -> Dictionary<String,Any>?{
            let data = try? JSONEncoder().encode(self)
            if data == nil { return nil }
            
            return Util.convertJsonDataToDic(data!)
        }

        // firesotreに書き込み
        func update() -> Bool {
            // structをdicに変換
            let dic = convertDic()
            if dic == nil { return false }
                    
            // firestoreに書き込み
            let db = Firestore.firestore()
            db.collection(DataKey.rooms.rawValue).document(DataKey.roomNo.rawValue).setData(dic!){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    // 成功処理
                }
            }
            // 本当はwriteを待つ予定だが、非同期なので成功することを信じて成功とみなす
            return true
        }
    }
    
    
    // ---- Class Method ----
    public class func createRoomNo(_ completion:@escaping(_ rn:RoomNo?)->Void){
        var roomNo:RoomNo?
        let db = Firestore.firestore()
        let rnRef = db.collection(DataKey.rooms.rawValue).document(DataKey.roomNo.rawValue)
        rnRef.getDocument { (document,err) in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    // 取得内容をstructに変換
                    let jsonData = Util.convertDoucumentDataToJsonData(document.data())
                    if jsonData == nil {
                        return
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let rn = try? decoder.decode(RoomNo.self, from: jsonData!)
                    if rn == nil {
                        return
                    }
                    // 成功!
                   roomNo = rn
                } else {
                    // 読み込み失敗
                    return
                }
                // 取得結果を返す
                completion(roomNo)
                return
            }
            
        }
    }
    
    public class func createRoom(_ rommNo:Int, _ title:String, _ pid:String) ->Room? {
        // room生成
        let r = Room.init(rommNo, title, pid)
        // 書き込み
        if !r.create(){
            // ここでreturnするとroomNoが無駄インクリメントになるが仕方がない
            return nil
        }
        
        return r
    }
    
    public static func getRoom(_ rNo:String) -> Room?{
        var ret:Room?
        // firestoreから読み込み
        let db = Firestore.firestore()
        db.collection(DataKey.rooms.rawValue).document(rNo).getDocument { (document, error) in
            if let document = document, document.exists {
                // 取得内容をstructに変換
                let jsonData = Util.convertDoucumentDataToJsonData(document.data())
                if jsonData == nil {
                    return
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let rm = try? decoder.decode(Room.self, from: jsonData!)
                if rm == nil {
                    return
                }
                // 成功!
                ret = rm
            }else{
                return
            }
        }
        
        return ret
    }
}
