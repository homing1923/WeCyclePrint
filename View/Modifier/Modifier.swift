//
//  Modifier.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-26.
//

import Foundation
import SwiftUI



struct ImgFrameModifier : ViewModifier{
    func body(content: Content) -> some View{
        return content
            .frame(width: 130, height: 200)
            .shadow(radius: 10)
            .cornerRadius(15)
            .shadow(radius: 10)
            .cornerRadius(10)
    }
}


struct AppTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .padding(10)
    }
}
