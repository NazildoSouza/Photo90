//
//  Shimmer.swift
//  Photo90
//
//  Created by Nazildo Souza on 13/07/20.
//  Copyright © 2020 Nazildo Souza. All rights reserved.
//

import SwiftUI

struct Shimmer: View {
    @State private var show = false
    var center = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            Color("Color")
                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 400 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 150 : 250))
                .cornerRadius(10)
            
            Color("Color2")
                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 400 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 150 : 250))
                .cornerRadius(10)
                .mask(
                    
                    Rectangle()
                        .fill(
                            LinearGradient(gradient: .init(colors: [.clear, Color.white.opacity(0.48), .clear]), startPoint: .top, endPoint: .bottom)
                        )
                        .rotationEffect(.init(degrees: 70))
                        .offset(x: self.show ? self.center : -self.center)
                    
                )
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(Animation.default.speed(0.28).delay(0).repeatForever(autoreverses: false)) {
                if #available(iOS 14.0, *) {
                    self.show.toggle()
                }
            }
        }
    }
}

struct Shimmer_Previews: PreviewProvider {
    static var previews: some View {
        Shimmer()
    }
}
