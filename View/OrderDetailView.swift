//
//  OrderDetailView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-30.
//

import SwiftUI

struct OrderDetailView: View {
    
    @EnvironmentObject var apiManager : modelPostManager
    @EnvironmentObject var l_user : l_user
    
    @State var totalCost : Double = 0.0
    @State var local_cart : [String:modelPost] = [:]
    var l_order : order
    
    var body: some View {
        List{
            ForEach(Array(local_cart.keys), id:\.self){key in
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
                    }
                }
            }
            
        }.onAppear{
            self.totalCost = 0
            let priceArry : [Double] = self.apiManager.modelPosts.map{p in
                return p.model_cost! * Double(l_user.cart[p.model_uid!] ?? 0)
            }
            for each in priceArry{
                self.totalCost += each
            }
            for each in l_order.items{
                if let model = self.apiManager.modelPosts.first(where: {
                    $0.model_uid! == each.key
                }){
                    local_cart[each.key] = model
                }
            }
        }
    }
}

struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        OrderDetailView(l_order: order(createdDate: Date(), items: [:], state: .placed))
    }
}
