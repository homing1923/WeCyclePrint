//
//  SignUpView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-24.
//

import SwiftUI

struct SignUpView: View {
    
    @State var emailInput : String = ""
    @State var passwordInput : String = ""
    @State var passwordInputConfirm : String = ""
    @State var f_cLicensePlate : String = ""
    @State var f_contactNumber : String = ""
    @State var alertText : String = ""
    @State var alertOn : Bool = false
    
    @EnvironmentObject var fireauthManager : FireAuthManager
    @EnvironmentObject var firestoreManager : FirestoreManager
    @EnvironmentObject var loc_user : l_user
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack{
            Form{
                Section("User Info"){
                    VStack{
                        HStack{
                            Text("Email")
                            Spacer()
                            TextField("Enter Email", text: $emailInput)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    VStack{
                        HStack{
                            Text("Password")
                            Spacer()
                            SecureField("Enter Password", text: $passwordInput)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    VStack{
                        HStack{
                            Text("PasswordConfirm")
                            Spacer()
                            SecureField("Enter Password again", text: $passwordInputConfirm)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                }
            }
            
            
            Button(action: {
                validation()
            }){
                Text("SignUp")
            }
        }
        .alert(isPresented: $alertOn){
            Alert(title: Text(self.alertText), dismissButton: .default(Text("OK")))
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
        if(passwordInputConfirm.isEmpty){
            alertOn = true
            alertText = ValidationErrors.PasswordEmpty.rawValue
            return
        }
        if(passwordInput != passwordInputConfirm){
            alertOn = true
            alertText = ValidationErrors.PasswordNotEqual.rawValue
            return
        }
        
        
        self.fireauthManager.signUp(email: self.emailInput, password: self.passwordInput, completion: {useremail, err in
            if let err = err{
                alertOn = true
                alertText = err.localizedDescription
            }
            
            if let useremail = useremail{
                print(#function, "login success, \(useremail)")
                alertOn = true
                alertText = ValidationErrors.SignUpSuccess.rawValue
                var newUser = l_user(username: useremail, email: useremail, point: 100.0, orderList: [], cart: [:])
                loc_user.email = useremail
                loc_user.username = useremail
                self.firestoreManager.insertNewUserInfo(username: useremail, newUser: newUser)
                dismiss()
                
            }else{
                alertOn = true
                alertText = ValidationErrors.LoginFail.rawValue
            }
            
        })
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
