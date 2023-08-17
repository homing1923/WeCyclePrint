//
//  fireauthManager.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-28.
//

import Foundation
import FirebaseAuth
import FirebaseAuthCombineSwift

class FireAuthManager : ObservableObject{
    
    @Published var userLoggedIn : Bool = false
    @Published var user : User?{
        didSet{
            objectWillChange.send()
        }
    }
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener{[weak self] _, user in
            guard let self = self else{
                return
            }
            self.user = user
            
        }
        
    }
    
    func signUp(email:String, password:String,  completion: @escaping ( (String?, Error?) -> Void )){
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            authResult, error in
            if let err = error{
                completion(nil, error)
                print(err)
            }
            guard authResult != nil else{
                print(#function, "result is nil")
                return
            }
            
            switch authResult{
            case .none:
                print(#function, "Account creation fail")
                completion(nil, error)
            case .some(_):
                print(#function, "Account creation success")
                completion(authResult?.user.email, nil)
            }
        })
    }
    
    func signIn(email:String, password:String, completion: @escaping ( (String?, Error?) -> Void )) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            authResult, error in
            if let err = error{
                completion(nil, error)
                print(err)
            }
            switch authResult{
            case .none:
                print(#function, "Unable to find the user account")
                completion(nil, error)
            case .some(_):
                print(#function, "Login Successful")
                self.userLoggedIn = true
                self.user = authResult?.user
                completion(authResult?.user.email, nil)
            }
        })
        
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
    }
    
    func deleteAcc(complete: @escaping (Error?) -> Void){
        Auth.auth().currentUser?.delete(completion: {err in
            if let err = err{
                complete(err)
            }else{
                complete(nil)
            }
        })
    }
}
