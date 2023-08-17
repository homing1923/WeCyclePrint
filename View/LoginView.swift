//
//  LoginView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var fireauthManager : FireAuthManager
    @EnvironmentObject var firestoreManager : FirestoreManager
    @EnvironmentObject var loc_user : l_user
    
    @State var emailInput : String = ""
    @State var passwordInput : String = ""
    @State var alertText : String = ""
    @State var alertOn : Bool = false
    @State var navInt : Int? = nil
    
    
    var body: some View {
        ZStack{
            Image("Image1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.trailing, 150)
                .edgesIgnoringSafeArea(.all)
            VStack {
                GroupBox(label: Label("Login to Print", systemImage: "leaf.fill")){
                    Spacer()
                    TextField("Email", text: $emailInput)
                        .padding(.vertical)
                    SecureField("Password", text: $passwordInput)
                        .padding(.vertical)
                    Spacer()
                    NavigationLink(destination: SignUpView()){
                        Button(action: {
                            self.navInt = 2
                        }){
                            Text("SignUp")
                        }
                    }
                    .padding(.bottom)
                    NavigationLink(destination: MainView()){
                        Button(action: {
                            validation()
                        }){
                            Text("Login")
                        }
                    }
                    
                    
                }
                .frame(height: 300)
                .alert(isPresented: $alertOn){
                    Alert(title: Text(self.alertText), dismissButton: .default(Text("OK")))
                }
            }
            .onAppear{
                if(!loc_user.email.isEmpty){
                    self.emailInput = loc_user.email
                }
            }
            .imageScale(.large)
            .padding()
        }
    }
    
    func validation(){
        if(emailInput.isEmpty){
            alertOn = true
            alertText = ValidationErrors.EmailEmpty.rawValue
            return
        }
        if(!emailInput.contains("@") || !emailInput.contains(".")){
            alertOn = true
            alertText = ValidationErrors.EmailFormatError.rawValue
            return
        }
        if(passwordInput.isEmpty){
            alertOn = true
            alertText = ValidationErrors.PasswordEmpty.rawValue
            return
        }
        
        fireauthManager.signIn(email: emailInput, password: passwordInput, completion: {useremail, err in
            if let err = err{
                alertOn = true
                alertText = err.localizedDescription
            }
            
            if let useremail = useremail{
                print(#function, "login success, \(useremail)")
                loc_user.email = useremail
                self.firestoreManager.retrieveUserInfo(username: useremail, completion: {userInfo in
                    if let userInfo = userInfo{
                        self.loc_user.username = userInfo.username
                        self.loc_user.uid = userInfo.uid
                        self.loc_user.email = userInfo.email
                        self.loc_user.point = userInfo.point
                        self.loc_user.cart = userInfo.cart
                        self.loc_user.orderList = userInfo.orderList
                        self.navInt = 1
                    }
                    
                })
                
                
            }else{
                alertOn = true
                alertText = ValidationErrors.LoginFail.rawValue
            }
            
        })
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
