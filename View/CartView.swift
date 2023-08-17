//
//  CartView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-29.
//

import SwiftUI


struct CartView: View {
    
    @EnvironmentObject var apiManager : modelPostManager
    @EnvironmentObject var firestoreManager : FirestoreManager
    @EnvironmentObject var l_user : l_user
    
    @State var navInt : Int? = nil
    @State var totalCost : Double = 0
    @State var local_cart : [String:modelPost] = [:]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Spacer()
                    Text("Cart")
                    Spacer()
                }
                .padding()
                if(l_user.cart.isEmpty){
                    Spacer()
                    Text("You have nothing in the cart")
                    Spacer()
                }else{
                    List{
                        ForEach(Array(local_cart.keys.sorted()), id:\.hashValue){key in
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
                        
                        
                        
                        .onDelete(perform: {idxSet in
                            for idx in idxSet{
                                let key = Array(l_user.cart.keys.sorted())[idx]
                                l_user.cart.removeValue(forKey: key)
                                local_cart.removeValue(forKey: key)
                            }
                            self.totalCost = 0
                            let priceArry : [Double] = self.apiManager.modelPosts.map{p in
                                return p.model_cost! * Double(l_user.cart[p.model_uid!] ?? 0)
                            }
                            for each in priceArry{
                                self.totalCost += each
                            }
                            self.firestoreManager.updateOneInfo(username: l_user.username, updatedInfo: l_user, completion: {success in
                                
                            })
                        })
                    }
                    .onAppear{
                        self.totalCost = 0
                        let priceArry : [Double] = self.apiManager.modelPosts.map{p in
                            return p.model_cost! * Double(l_user.cart[p.model_uid!] ?? 0)
                        }
                        for each in priceArry{
                            self.totalCost += each
                        }
                        for each in self.l_user.cart{
                            if let model = self.apiManager.modelPosts.first(where: {
                                $0.model_uid! == each.key
                            }){
                                local_cart[each.key] = model
                            }
                        }
                    }
                    Text("Total Cost: \(String(format:"%.2f",self.totalCost))")
                    NavigationLink(destination: CheckOutView(local_cart: local_cart, completion: {
                        dismiss()
                    }),tag: 99, selection: $navInt){
                        Button(action: {
                            navInt = 99
                        }){
                            Text("CheckOut")
                        }
                    }
                }
                
            }
        }
    }
}


struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
