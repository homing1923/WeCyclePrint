//
//  ContentView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firestoreManager : FirestoreManager
    @EnvironmentObject var fireauthManager : FireAuthManager
    @EnvironmentObject var locatioManager : LocationManager
    @EnvironmentObject var l_user : l_user
    
    @Environment(\.dismiss) private var dismiss
    
    @State var f_bCode : String = ""
    @State var f_cLicensePlate : String = ""
    @State var f_SuitNumber : String = ""
    @State var f_location : String = ""
    @State var f_location_lan : Double = 0.0
    @State var f_location_lng : Double = 0.0
    @State var alertOn : Bool = false
    @State var alertText : String = ""
    
    
    var body: some View {
        VStack {
            Form{
                Section("Park Info"){
                    VStack{
                        HStack{
                            Text("Building Code")
                            Spacer()
                            TextField("Building Code", text: $f_bCode)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
//                    Picker("Hours", selection: $f_pHourSelection){
//                        ForEach(parkHours.allCases, id: \.self){tag in
//                            Text(tag.rawValue)
//                        }
//                    }
                    VStack{
                        HStack{
                            Text("License Plate")
                            Spacer()
                            TextField("License Plate", text: $f_cLicensePlate)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    VStack{
                        HStack{
                            Text("Suit Number")
                            Spacer()
                            TextField("Suit Number", text: $f_SuitNumber)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                Section("Location"){
                    VStack{
                        TextField("Location", text: $f_location)
                            .multilineTextAlignment(.center)
                            .frame(height: 80)
                        VStack{
                            Button(action: {
                                self.locatioManager.doReverseGeocoding(location: self.locatioManager.currentLocation ?? self.locatioManager.lastKnownLocation, completionHandler: {locStr, err in
                                    self.f_location = locStr ?? "Unknown"
                                    if let locStr = locStr{
                                        self.locatioManager.doForwardGeocoding(address: locStr){loc in
                                            self.f_location_lan = loc.coordinate.latitude
                                            self.f_location_lng = loc.coordinate.longitude
                                        }
                                    }
                                })
                                
                            }){
                                Text("Use My Location")
                            }
                            
                            .buttonStyle(BorderlessButtonStyle())
                            .padding()
                            Button(action: {
                                self.locatioManager.doForwardGeocoding(address: self.f_location){loc in
                                    self.f_location_lan = loc.coordinate.latitude
                                    self.f_location_lng = loc.coordinate.longitude
                                    self.alertOn = true
                                    self.alertText = ValidationErrors.AddressConvertionSuccess.rawValue
                                }
                            }){
                                Text("Convert My address")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                
            }
            Button(action: {
                validation()
            }){
                Text("ADD")
            }
        }
        .alert(isPresented: $alertOn){
            Alert(title: Text(self.alertText), dismissButton: .default(Text("OK")))
        }
        
    }
    
    func validation(){
//        let validationConditions = [
//
//        ]
//
//        for condition in validationConditions {
//            if condition.0 {
//                self.alertText = condition.1
//                self.alertOn = true
//                return
//            }
//        }
        self.firestoreManager
            .insertOneOrder(
                username: l_user.email,
                newOrder:
                    order(createdDate: Date(), items: self.l_user.cart, state: .placed), completion:{success in
                               if(success){
                                   self.alertText = ValidationErrors.OrderSuccessfullyAdded.rawValue
                               }else{
                                   self.alertText = ValidationErrors.OrderFailedToAdded.rawValue
                               }
                               self.alertOn = true
                    })
        //        if (f_bCode.isEmpty){
        //            self.alertText = ValidationErrors.BuildCodeEmpty.rawValue
        //            return
        //        }
        //        if ((f_bCode.firstMatch(of: /[A-Za-z0-9]{5}/)) == nil){
        //            self.alertText = ValidationErrors.BuildCodeFormatInvalid.rawValue
        //            return
        //        }
        //        if (f_cLicensePlate.isEmpty){
        //            self.alertText = ValidationErrors.LicensePlateEmpty.rawValue
        //            return
        //        }
        //        if ((f_cLicensePlate.firstMatch(of: /[A-Za-z0-9]{2,8}/)) == nil){
        //            self.alertText = ValidationErrors.LicensePlateFormatInvalid.rawValue
        //            return
        //        }
        //        if (f_SuitNumber.isEmpty){
        //            self.alertText = ValidationErrors.SuitNumberEmpty.rawValue
        //            return
        //        }
        //        if ((f_SuitNumber.firstMatch(of: /[A-Za-z0-9]{2,5}/)) == nil){
        //            self.alertText = ValidationErrors.SuitNumberFormatInvalid.rawValue
        //            return
        //        }
        //        if(f_location.isEmpty || f_location_lan == 0.0 || f_location_lng == 0.0){
        //            self.alertText = ValidationErrors.LocationEmpty.rawValue
        //            return
        //        }
    }
    
}
