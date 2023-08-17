//
//  CheckOutView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-29.
//

import SwiftUI

struct CheckOutView: View {
    
    @EnvironmentObject var l_user : l_user
    @EnvironmentObject var apiManager : modelPostManager
    @EnvironmentObject var firestoreManager : FirestoreManager
    
    @State var totalCost : Double = 0
    @State var pointNotEnough : Bool = true
    
    @State var alertOn : Bool = false
    @State var alertText : String = ""
    
    var local_cart : [String:modelPost]
    var completion : () -> Void
    
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("Order Confirmation")
                Spacer()
            }
            List{
                ForEach(Array(local_cart.keys), id:\.self.hashValue){key in
                    VStack{
                        HStack{
                            HStack{
                                Image(uiImage: (local_cart[key]!.model_imgArry![0]))
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                Spacer()
                                Text((local_cart[key]?.model_name)!)
                                Spacer()
                                Text(String(format:"%.2f",local_cart[key]!.model_cost!))
                                
                            }
                            Text("x" + String(format:"%d", l_user.cart[local_cart[key]!.model_uid!] ?? 0))
                        }
                        
                    }
                    
                }
            }
            .onAppear{
                self.totalCost = 0
                let priceArry : [Double] = self.apiManager.modelPosts.map{p in
                    return p.model_cost! * Double(l_user.cart[p.model_uid!] ?? 0)
                }
                for each in priceArry{
                    self.totalCost += each
                }
                if(l_user.point >= self.totalCost){
                    self.pointNotEnough = false
                }
            }
            VStack{
                Text("Current Point : \(String(format:"%.2f",l_user.point))")
                Text("Purchasing : \(String(format:"%.2f",self.totalCost))")
                Text("Remaining : \(String(format:"%.2f",l_user.point-self.totalCost))")
            }
            .padding(.bottom)
            
            Button(action: {
                firestoreManager.insertOneOrder(username: l_user.username, newOrder: order(createdDate: Date(), items: self.l_user.cart, state: .placed), completion: {success in
                    if(success){
                        l_user.point -= self.totalCost
                        l_user.cart.removeAll()
                        print(#function, "order post success")
                        firestoreManager.updateOneInfo(username: l_user.username, updatedInfo: l_user, completion: {success in
                            if(success){
                                self.alertText = ValidationErrors.OrderSuccessfullyAdded.rawValue
                            }else{
                                self.alertText = ValidationErrors.OrderFailedToAdded.rawValue
                            }
                            
                        })
                    }else{
                        self.alertText = ValidationErrors.OrderFailedToAdded.rawValue
                        print(#function, "order post fail")
                    }
                    self.alertOn = true
                    completion()
                    
                })
            }){
                Text("Order!!!")
            }
            .disabled(pointNotEnough)
        }
        .alert(isPresented: $alertOn){
            Alert(title: Text(self.alertText), dismissButton: .default(Text("OK")))
        }
    }
}

struct CheckOutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckOutView(local_cart:[:], completion: {
            
        })
    }
}
