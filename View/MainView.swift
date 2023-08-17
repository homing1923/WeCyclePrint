//
//  MainView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-29.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var firestoreManager : FirestoreManager
    @EnvironmentObject var fireauthManager : FireAuthManager
    @EnvironmentObject var locationManager : LocationManager
    @EnvironmentObject var apiManager : modelPostManager
    @EnvironmentObject var loc_user : l_user
    
    
    @Environment(\.dismiss) private var dismiss
    
    @State var tagInt : Int = 0
    @State var showCart : Bool = false
    let titlebarArry : [String] = ["Prints Library", "Path To Recycle", "Orders"]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            
            TabView(selection: $tagInt, content: {
                
                PrintsView()
                    .tag(0)
                    .tabItem(){
                        Image(systemName: "heart.fill")
                        Text("Prints")
                    }
                LocationMapView()
                    .tag(1)
                    .tabItem(){
                        Image(systemName: "map")
                        Text("RecyclePoint")
                    }
                OrderView()
                    .tag(2)
                    .tabItem(){
                        Image(systemName: "house")
                        Text("Orders")
                    }
                
                
            })
            .sheet(isPresented: $showCart, onDismiss: {
                showCart = false
            }, content: {CartView()})
            .navigationBarBackButtonHidden()
            .navigationTitle(Text(titlebarArry[tagInt]))
            .navigationBarTitleDisplayMode(.large)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Text("Hello! \(loc_user.username)")
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        
                        self.firestoreManager.updateOneInfo(username: loc_user.username, updatedInfo: loc_user, completion: {success in
                            if(success){
                                self.fireauthManager.signOut()
                                print(#function, "successfully to here")
                                firestoreManager.retrievedOrders.removeAll()
                                firestoreManager.removeListener()
                                firestoreManager.removeInfoListener()
                                loc_user.cart.removeAll()
                                loc_user.orderList.removeAll()
                                dismiss()
                            }
                            
                            
                        })
                        
                    }){
                        Text("SignOut")
                    }
                })
            }
            if(tagInt == 0){
                Button(action: {
                    showCart = true
                }){
                    
                    Image(uiImage: UIImage(systemName: "cart")!)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(15)
                        .background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle())
                        
                }
                
                .padding(.trailing, 30)
                .padding(.bottom, 75)
            }
            
            
        }
        .environmentObject(apiManager)
        .environmentObject(fireauthManager)
        .environmentObject(firestoreManager)
        .environmentObject(locationManager)
        .environmentObject(loc_user)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
