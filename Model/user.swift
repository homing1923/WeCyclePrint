//
//  user.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-28.
//

import Foundation

class l_user : ObservableObject{
    var uid: String
    var username: String
    var email : String
    var point : Double = 100.0
    var orderList : [order] = []
    var cart : [String:Int] = [:]
    
    convenience init(){
        self.init(username: "", email: "", point: 100.0, orderList: [order](), cart: [String:Int]())
    }
    
    init(uid: String = "", username:String, email: String, point: Double, orderList:[order], cart:[String:Int]){
        self.uid = uid
        self.username = username
        self.email = email
        self.point = point
        self.orderList = orderList
        self.cart = cart
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case username
        case email
        case point
        case orderList
        case cart
    }
    
    convenience init?(uid:String, dict: [String: Any]){
        guard let l_username = dict[CodingKeys.username.rawValue] as? String else{
            return nil
        }
        guard let l_email = dict[CodingKeys.email.rawValue] as? String else{
            return nil
        }
        guard let l_point = dict[CodingKeys.point.rawValue] as? Double else{
            return nil
        }
        guard let l_orderlist = dict[CodingKeys.orderList.rawValue] as? [order] else{
            return nil
        }
        guard let l_cart = dict[CodingKeys.cart.rawValue] as? [String:Int] else{
            return nil
        }
        
        self.init(uid:uid, username:l_username, email:l_email, point: l_point, orderList: l_orderlist, cart: l_cart)
    }
    
    func convertToFirebaseObj() -> [String:Any]{
        var container = [String:Any]()
        container["email"] = (self.email as String)
        container["uid"] = (self.uid as String)
        container["username"] = (self.username as String)
        container["point"] = (self.point as Double)
        container["orderList"] = (self.orderList as [order])
        container["cart"] = (self.cart as [String:Int])
        return container
    }
    

}
