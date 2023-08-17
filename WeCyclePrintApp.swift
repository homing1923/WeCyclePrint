//
//  WeCyclePrintApp.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-22.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct WeCyclePrintApp: App {
    let apiManager : modelPostManager
    let firestoreManager : FirestoreManager
    let fireauthManager : FireAuthManager
    let locationManager : LocationManager
    var loc_user : l_user
    
    init(){
        FirebaseApp.configure()
        firestoreManager = FirestoreManager(store: Firestore.firestore())
        fireauthManager = FireAuthManager()
        locationManager = LocationManager()
        apiManager = modelPostManager()
        loc_user = l_user()
    }
    
    @State var tabInt = 1

    var body: some Scene {
        
        WindowGroup {
            NavigationView{
                MainView()
//                LoginView()
            }
            .environmentObject(fireauthManager)
            .environmentObject(firestoreManager)
            .environmentObject(locationManager)
            .environmentObject(apiManager)
            .environmentObject(loc_user)
        }
    }
}
