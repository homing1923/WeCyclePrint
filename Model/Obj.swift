//
//  Obj.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-24.
//

import Foundation
import SwiftUI

class modelClassPost{
    var model_uid : String?
    var model_name : String?
    var model_author : String?
    var model_authorImgLink : String?
    var model_authorImg : UIImage? = nil
    var model_createdDate : String?
    var model_imgLinks : [String]?
    var model_imgArry : [UIImage]?
    var model_cost : Double?
    var model_material : [String]?
    
    init(uid:String?, name: String?, author: String?, authorImgLink: String?, authorImg: UIImage?, createdDate: String?, imgLinks: [String]?, imgArry: [UIImage]?, cost: Double?, material: [String]?) {
        self.model_uid = uid
        self.model_name = name
        self.model_author = author
        self.model_authorImgLink = authorImgLink
        self.model_authorImg = authorImg
        self.model_createdDate = createdDate
        self.model_imgLinks = imgLinks
        self.model_imgArry = imgArry
        self.model_cost = cost
        self.model_material = material
    }
}

struct modelPost: Codable{
    //json struct key
    enum modelPostKey : CodingKey{
        case model
        enum modelKey : String, CodingKey{
            case uid, name, author, authorImg, date, img, cost, material
        }
    }
    
    var model_uid : String?
    var model_name : String?
    var model_author : String?
    var model_authorImgLink : String?
    var model_authorImg : UIImage? = nil
    var model_createdDate : String?
    var model_imgLinks : [String]?
    var model_imgArry : [UIImage]?
    var model_cost : Double?
    var model_material : [String]?
    
    //    var ui_currentId : Int = 0
    
    init(uid:String?, name: String?, author: String?, authorImgLink: String?, createdDate: String?, imgLinks: [String]?, cost: Double?, material: [String]?) {
        self.model_uid = uid
        self.model_name = name
        self.model_author = author
        self.model_authorImgLink = authorImgLink
        self.model_createdDate = createdDate
        self.model_imgLinks = imgLinks
        self.model_cost = cost
        self.model_material = material
    }
    
    init(uid:String?, name: String?, author: String?, authorImgLink: String?, authorImg: UIImage?, createdDate: String?, imgLinks: [String]?, imgArry: [UIImage]?, cost: Double?, material: [String]?) {
        self.model_uid = uid
        self.model_name = name
        self.model_author = author
        self.model_authorImgLink = authorImgLink
        self.model_authorImg = authorImg
        self.model_createdDate = createdDate
        self.model_imgLinks = imgLinks
        self.model_imgArry = imgArry
        self.model_cost = cost
        self.model_material = material
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: modelPostKey.self)
        
        let modelContainer = try container.nestedContainer(keyedBy: modelPostKey.modelKey.self, forKey: .model)
        self.model_uid = try modelContainer.decode(String.self, forKey: .uid)
        self.model_name = try modelContainer.decodeIfPresent(String.self, forKey: .name)
        self.model_author = try modelContainer.decodeIfPresent(String.self, forKey: .author)
        self.model_authorImgLink = try modelContainer.decodeIfPresent(String.self, forKey: .authorImg)
        self.model_createdDate = try modelContainer.decodeIfPresent(String.self, forKey: .date)
        self.model_imgLinks = try modelContainer.decodeIfPresent([String].self, forKey: .img)
        self.model_cost = try modelContainer.decodeIfPresent(Double.self, forKey: .cost)
        self.model_material = try modelContainer.decodeIfPresent([String].self, forKey: .material)
    }
    
    init?(item: [String: Any]) {
        guard let uid = item["uid"] as? String else{
            return nil
        }
        
        guard let name = item["name"] as? String else {
            return nil
        }
        
        guard let author = item["author"] as? String else {
            return nil
        }
        
        guard let authorImg = item["authorImg"] as? String else {
            return nil
        }
        
        guard let date = item["date"] as? String else {
            return nil
        }
        
        guard let cost = item["cost"] as? Double else {
            return nil
        }
        
        guard let img = item["img"] as? [String] else {
            return nil
        }
        
        guard let material = item["material"] as? [String] else {
            return nil
        }
        
        // assign the values to properties
        self.init(uid: uid, name: name, author: author, authorImgLink: authorImg, createdDate: date, imgLinks: img, cost: cost, material: material)
    }
    
    func encode(to encoder: Encoder) throws {
        
        //
    }
    
    func toClass() -> modelClassPost {
        return modelClassPost(uid: model_uid,
                              name: model_name,
                              author: model_author,
                              authorImgLink: model_authorImgLink,
                              authorImg: model_authorImg,
                              createdDate: model_createdDate,
                              imgLinks: model_imgLinks,
                              imgArry: model_imgArry,
                              cost: model_cost,
                              material: model_material)
    }
}
