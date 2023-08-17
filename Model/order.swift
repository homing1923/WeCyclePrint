//
//  order.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-28.
//

import Foundation
import FirebaseFirestore

enum orderState :String{
    case placed, confirmed, ready, delivering, delivered, finished
}

enum ValidationErrors : String{
    case OrderSuccessfullyAdded,
         OrderFailedToAdded,
         LocationEmpty,
         OrderSuccessfullyUpdated,
         OrderUpdatedFailed,
         UsernameEmpty,
         ContactEmpty,
         PasswordEmpty,
         UserInfoUpdateSuccess,
         UserInfoUpdateFail,
         EmailEmpty,
         EmailFormatError,
         LoginFail,
         SignUpSuccess,
         PasswordNotEqual,
         AddressConvertionSuccess,
         DeleteAccountComplete,
         DeleteAccountFail
}

class order : Codable{
    var uid : String = ""
    var createdDate : Date = Date()
    var items : [String:Int] = [:]
    var state : orderState
    
    func toFirestoreObj() -> [String:Any]{
        var newdata = [String:Any]()
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach{prop in
            newdata[prop.label!] = prop.value
        }
        newdata["state"] = (newdata["state"] as? orderState)?.rawValue
        return newdata
    }
    
    convenience init?(uid:String, dict: [String:Any]){
        guard let cDate = dict[CodingKeys.createdDate.rawValue] as? Timestamp else{
            return nil
        }
        guard let i = dict[CodingKeys.items.rawValue] as? [String:Int] else{
            return nil
        }
        guard let s = dict[CodingKeys.state.rawValue] as? String else{
            return nil
        }
        self.init(uid: uid, createdDate: cDate.dateValue(), items: i, state: orderState(rawValue: s)!)
     }
    
    init(uid:String = "", createdDate: Date, items: [String:Int], state: orderState) {
        self.createdDate = createdDate
        self.items = items
        self.state = state
    }
    
    required init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.createdDate = try container.decode(Date.self, forKey: .createdDate)
        self.items = try container.decode([String:Int].self, forKey: .items)
        self.state = orderState(rawValue: try container.decode(String.self, forKey: .state))!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(items, forKey: .items)
        try container.encode(state.rawValue, forKey: .state)
    }
    
    private enum CodingKeys: String, CodingKey {
        case uid
        case createdDate
        case items
        case state
    }
}
