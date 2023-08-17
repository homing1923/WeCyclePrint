//
//  OrderView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-30.
//

import SwiftUI

struct OrderView: View {
    @EnvironmentObject var firestoreManager : FirestoreManager
    @EnvironmentObject var l_user : l_user
    
    @State var local_cart : [String:modelPost] = [:]
    @State var alertOn : Bool = false
    @State var alertText : String = ""
    
    var body: some View {
        VStack{
            if(firestoreManager.retrievedOrders.isEmpty){
                Spacer()
                Text("You do not have any order yet!")
                Spacer()
            }else{
                List{
                    ForEach(self.firestoreManager.retrievedOrders, id: \.createdDate.hashValue){ord in
                        NavigationLink(destination: OrderDetailView(l_order: ord)){
                                HStack{
                                    Image(uiImage: UIImage(systemName: "shippingbox")!)
                                        .resizable()
                                        .frame(width: 40,height: 40)
                                    Spacer()
                                    Text("Created: \(ord.createdDate.formatted())")
                                    Spacer()
                                    Text(ord.state.rawValue)
                                }
                        }
                        
                    }
                }
            }
        }
        .onAppear{
            firestoreManager.retrieveAllOrder(usename: l_user.username, completion: {
                print(#function, "finished retrieve, item count = \(self.firestoreManager.retrievedOrders)")
                self.firestoreManager.retrievedOrders.sort(by: {
                    $0.createdDate > $1.createdDate
                })
            })
        }
        .onDisappear{
            firestoreManager.removeListener()
        }
        .alert(isPresented: $alertOn){
            Alert(title: Text(self.alertText), dismissButton: .default(Text("OK")))
        }
    }
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}
