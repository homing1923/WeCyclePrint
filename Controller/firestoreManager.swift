//
//  firestoreManager.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-28.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuthCombineSwift

class FirestoreManager : ObservableObject{
    private let store : Firestore
    public static var shared : FirestoreManager?
    private var listener : ListenerRegistration? = nil
    private var infoListener : ListenerRegistration? = nil
    
    private let collectionUser : String = "printusers"
    private let collectionInfo : String = "info"
    private let collectionOrder : String = "order"
    
    @Published var retrievedOrders = [order]()
    
    static func getInstance() -> FirestoreManager?{
        if(shared == nil){
            shared = FirestoreManager(store: Firestore.firestore())
        }
        return shared
    }
    
    init(store: Firestore) {
        self.store = store
    }
    
    func deleteAcc(username:String, complete: @escaping (Error?) -> Void){
        self.store
            .collection(collectionUser)
            .document(username)
            .collection(collectionInfo)
            .getDocuments(completion: {Snap, err in
                Snap?.documents.forEach({each in
                    self.store
                        .collection(self.collectionUser)
                        .document(username)
                        .collection(self.collectionInfo)
                        .document(each.documentID)
                        .delete()
                })
                if let err = err{
                    complete(err)
                }else{
                    complete(nil)
                }
            })
    }
    
    func updateOneOrder(username:String, updatedOrder: order, completion: @escaping (Bool) -> Void){
        self.store
            .collection(self.collectionUser)
            .document(username)
            .collection(self.collectionOrder)
            .document(updatedOrder.uid)
            .setData(updatedOrder.toFirestoreObj(), completion: {err in
                if let err = err{
                    print(#function, err)
                    completion(false)
                }else{
                    completion(true)
                }
            })
            
            
    }
    
    func updateOneInfo(username:String, updatedInfo: l_user, completion: @escaping (Bool) -> Void){
        self.store
            .collection(self.collectionUser)
            .document(username)
            .collection(self.collectionInfo)
            .document(updatedInfo.uid)
            .setData(updatedInfo.convertToFirebaseObj(), completion: {err in
                if let err = err{
                    print(#function, err)
                    completion(false)
                }else{
                    completion(true)
                }
            })
            
            
    }
    
    func insertOneOrder(username: String, newOrder: order, completion: @escaping (Bool) -> Void){
        let newoBj = newOrder.toFirestoreObj()
        print(#function, newoBj)
        self.store
            .collection(self.collectionUser)
            .document(username)
            .collection(self.collectionOrder)
            .addDocument(data: newoBj, completion: {err in
                if let err = err{
                    print(#function, err)
                    completion(false)
                }else{
                    completion(true)
                }
            })
    }
    
    func deleteOneOrder(username: String, orderIdx: IndexSet, completion: @escaping (Bool) -> Void){
        let docId = self.retrievedOrders[orderIdx.first!].uid
        self.store
            .collection(self.collectionUser)
            .document(username)
            .collection(self.collectionOrder)
            .document(docId)
            .delete(completion: {err in
                if let err = err{
                    print(#function, err)
                    completion(false)
                }else{
                    completion(true)
                }
            })
        
            
    }
    
    func removeListener(){
        self.listener?.remove()
    }
    
    func removeInfoListener(){
        self.listener?.remove()
    }
    
    func retrieveUserInfo(username: String, completion: @escaping (l_user?) -> Void){
        self.infoListener = self.store
            .collection(self.collectionUser)
            .document(username)
            .collection(collectionInfo)
            .addSnapshotListener{qsnap, err in
                qsnap?.documentChanges.forEach{doc in
                    if let castedInfo = l_user(uid: doc.document.documentID, dict: doc.document.data()){
                        switch(doc.type){
                        case.added:
                            completion(castedInfo)
                        case .modified:
                            completion(castedInfo)
                            print(#function, "modified")
                        case .removed:
                            print(#function, "deleted")
                            completion(nil)
                        }
                    }else{
                        print(#function, "Fail to cast")
                    }
                }
                
            }
    }
    
    func retrieveAllOrder(usename:String, completion: @escaping () -> Void){
        self.retrievedOrders.removeAll()
        self.listener = self.store
            .collection(self.collectionUser)
            .document(usename)
            .collection(self.collectionOrder)
            .addSnapshotListener{qsnap, err in
                qsnap?.documentChanges.forEach{doc in
                    if let castedOrder = order(uid:doc.document.documentID, dict: doc.document.data()){
                        switch(doc.type){
                        case .added:
                            print(#function, "added!")
                            self.retrievedOrders.append(castedOrder)
                        case .modified:
                            if let idx = self.retrievedOrders.firstIndex(where:{
                                $0.createdDate == castedOrder.createdDate
                            }){
                                self.retrievedOrders.remove(at: idx)
                                self.retrievedOrders.insert(castedOrder, at: idx)
                            }
                            
                        case .removed:
                            if let idx = self.retrievedOrders.firstIndex(where:{
                                $0.createdDate == castedOrder.createdDate
                            }){
                                self.retrievedOrders.remove(at: idx)
                            }
                        }
                    }else{
                        print(#function, "Fail to cast")
                    }
                }
                completion()
                
            }
    }
    
    func insertNewUserInfo(username: String, newUser : l_user){
        let ref = self.store
            .collection(self.collectionUser)
            .document(username)
            .collection(self.collectionInfo)
            .addDocument(data: newUser.convertToFirebaseObj())
    }
}
