//
//  PrintsView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-23.
//

import SwiftUI

struct PrintsView: View {
    var L_list : [Int] = Array(0...10)
    @State var currentImage : Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var isLoading = true
    @State private var addBtn = false
    @State private var alertOn = false
    
    @EnvironmentObject var apiManager : modelPostManager
    @EnvironmentObject var firestoreManager : FirestoreManager
    @EnvironmentObject var loc_user : l_user
    
    var body: some View {
        if(isLoading){
            ProgressView()
                .onAppear {
                    self.apiManager.modelPosts.removeAll()
                    Task {
                        await apiManager.fetchTest(WithCompletion: {posts in
                            isLoading = false
                        })
                    }
                }
        }else{
            ZStack{
                Image("Image1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.trailing, 150)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.3)
                VStack{
                    ScrollView{
                        ForEach(self.apiManager.modelPosts, id:\.model_uid?.hash){item in
                            box(post: item, simpleMode: false)
                        }
                    }
                }
                .background(Color(red: 0.855, green: 0.976, blue: 0.941, opacity: 0.75))
                .alert(isPresented:$alertOn){
                    Alert(title: Text("Added!"),dismissButton: .cancel())
                }
            }
            
        }
    }
    
    func box(post:modelPost, simpleMode: Bool) -> some View{
        return VStack{
            ZStack(alignment: .topTrailing){
                //body part
                VStack{
                    //Host
                    HostBar(post: post, haslikeBtn: !simpleMode)
                    //title
                    HStack{
                        Text(post.model_name!)
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .shadow(radius: 10)
                        Spacer()
                    }
                    .padding(.bottom)
                    HStack{
                        Text("Cost:" + String(format:"%.2f",post.model_cost!))
                            .font(.system(size: 12))
                            .foregroundColor(Color.white)
                            .shadow(radius: 10)
                        Spacer()
                    }
                    .padding(.bottom)
                    //bottom part
                    HStack{
                        //left image
                        if(!simpleMode){
                            ScrollViewReader{sv in
                                ScrollView(.horizontal){
                                    HStack{
                                        ForEach(Array(post.model_imgArry!.enumerated()), id: \.1){idx, x in
                                            Image(uiImage: x)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .id(idx)
                                        }
                                    }
                                    .padding(.leading, 10)
                                }
                                .onReceive(timer, perform: {_ in
                                    withAnimation(.spring(dampingFraction: 0.4).speed(2)){
                                        sv.scrollTo(self.currentImage, anchor: .leading)
                                        self.currentImage = (self.currentImage == 1 ? 0 : 1)
                                    }
                                })
                            }
                            .frame(height: 280, alignment: .leading)
                            .padding(.vertical)
                        }
                        
                    }
                    
                    .background(Color.init(red: 0.129, green: 0.01, blue: 0.141))
                    .cornerRadius(8)
                    .frame(alignment: .center)
                    .shadow(radius: 10)
                }
                .padding()
            }
            
        }
        .background(Color(red: 0.13, green: 0.01, blue: 0.13,opacity: 0.7))
        .cornerRadius(8)
        .padding(.horizontal, 10)
        
    }
    
    func heartbox(imgName: String, imgColour: Color) -> some View{
        return Image(systemName: imgName)
            .resizable()
            .padding()
            .foregroundColor(imgColour)
            .aspectRatio(contentMode: .fit)
            .frame(minWidth: 30,maxWidth: 58)
    }
    
    func HostBar(post:modelPost, haslikeBtn:Bool) -> some View{
        return HStack(content: {
            Image(uiImage: post.model_authorImg!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .cornerRadius(100)
            Text(post.model_author!)
                .foregroundColor(Color.white)
            Spacer()
            if(haslikeBtn){
                Button(action:{
                    addBtn(post: post)
                    self.alertOn = true
                }){
                    heartbox(imgName: "plus", imgColour: Color.black)
                }
                .animation(.spring(), value: addBtn)
            }
        })
    }
    
    func addBtn(post: modelPost){
        if let postUid = post.model_uid{
            if let currentItemNum = self.loc_user.cart[postUid]{
                self.loc_user.cart[postUid] = currentItemNum + 1
            }else{
                self.loc_user.cart[postUid] = 1
            }
            self.firestoreManager.updateOneInfo(username: loc_user.username, updatedInfo: loc_user, completion: {success in
                
            })
        }
        
    }
}

struct PrintsView_Previews: PreviewProvider {
    static var previews: some View {
        PrintsView().environmentObject(modelPostManager())
    }
}
