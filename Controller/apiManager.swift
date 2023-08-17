//
//  apiManager.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-24.
//

import Foundation
import SwiftUI

extension URL {
    func asyncTask(Withcompletion completion: @Sendable @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()){
        URLSession.shared
            .dataTask(with: self, completionHandler: completion)
            .resume()
    }
}

class modelPostManager : ObservableObject{
    @Published var modelPosts : [modelPost] = []
    
    private let base_url = "http://127.0.0.1:3000/api/testObj"
    
    func fetchTest(WithCompletion completion: @escaping ([modelPost]?) -> Void) async{
        
        guard let url = URL(string: base_url) else{
            return
        }
        let urlReq = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlReq) { (retrievedData : Data?, response : URLResponse?, error : Error?) in
            DispatchQueue.global().sync {
                guard let data = retrievedData, error == nil else{
                    return
                }
                do{
                    let parsedJson = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]]
                    DispatchQueue.main.async { 
                        if let arrayJson = parsedJson{
                            
                            for item in arrayJson{
                                if let newpost = modelPost(item: item){
                                    self.modelPosts.append(newpost)
                                }
                            }
                            
                            self.modelPosts = self.modelPosts.map{(p) -> modelPost in
                                let dispatchGroup = DispatchGroup()
                                var new_model_imgArry = [UIImage]()
                                var new_model_AuthorImg : UIImage? = nil
                                dispatchGroup.enter()
                                self.fetchImage(path: p.model_authorImgLink!, completion: {picData in
                                    if let picData = picData{
                                        if let Uiimage = UIImage(data: picData){
                                            new_model_AuthorImg = Uiimage
                                            dispatchGroup.leave()
                                        }
                                    }
                                })
                                dispatchGroup.wait()
                                if p.model_imgLinks!.count > 0{
                                    
                                    new_model_imgArry = p.model_imgLinks.map { img in
                                        var imgarry: [UIImage] = []
                                        for eachStr in img {
                                            dispatchGroup.enter()
                                            print(eachStr)
                                             // Enter the dispatch group before starting each task
                                                self.fetchImage(path: eachStr, completion: {picData in
                                                    if let picData = picData{
                                                        if let Uiimage = UIImage(data: picData){
                                                            imgarry.append(Uiimage)
                                                        }else{
                                                            print(#function, "Cast uiImage Error")
                                                        }
                                                    }else{
                                                        print(#function, "no picData")
                                                    }
                                                    dispatchGroup.leave()
                                                })
                                            dispatchGroup.wait()
                                        }
                                        print(#function, "imgarray with count : \(imgarry.count)")
                                        return imgarry
                                    }!
                                    
                                }
                                dispatchGroup.wait()
                                return modelPost(uid: p.model_uid, name: p.model_name, author: p.model_author, authorImgLink: p.model_authorImgLink, authorImg: new_model_AuthorImg, createdDate: p.model_createdDate, imgLinks: p.model_imgLinks,imgArry: new_model_imgArry ,cost: p.model_cost, material: p.model_material)
                            }
                            completion(self.modelPosts)
                        }
                    }
                    
                }catch{
                    print(#function, "Error in \(error)")
                }
            }
        }
        task.resume()
    }

        func fetchImage(path: String, completion: @escaping (Data?) -> Void) {
            print(#function, "fetch started")
            if let imgPath = URL(string:path){
                 imgPath.asyncTask(Withcompletion: {retrievedData, httpResponse, error in
                    guard let data = retrievedData else {
                            print("URLSession dataTask error:", error ?? "nil")
                            return
                        }
                    if(retrievedData != nil){
                        print(#function, "retrieved something")
                            completion(data)
                    }else{
                        print(#function, "nil returned")
                    }
                })
            }
        }
}
