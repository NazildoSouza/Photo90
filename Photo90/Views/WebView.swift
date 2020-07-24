//
//  WebView.swift
//  Photo90
//
//  Created by Nazildo Souza on 09/06/20.
//  Copyright © 2020 Nazildo Souza. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView: View {
    @ObservedObject var getData: GetData
    var photo: Photo
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if self.getData.indexWeb == 0 {
                Web(url: self.photo.links["html"] ?? "https://unsplash.com/")
                    .edgesIgnoringSafeArea(.all)
            } else if self.getData.indexWeb == 1 {
                Web(url: self.photo.user.portfolio_url ?? "https://unsplash.com/")
                    .edgesIgnoringSafeArea(.all)
            } else {
                Web(url: self.photo.urls["full"] ?? "https://unsplash.com/")
                .edgesIgnoringSafeArea(.all)
            }
      /*
            Button(action: {
                
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)){
                    
                    self.getData.showWeb = false
                }
                
            }) {
                
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(Blur(style: .systemMaterialDark))
                    .clipShape(Circle())
                
            }
            .padding([.trailing, .top], 5)
          //  .padding(.trailing, UIDevice.current.orientation.isLandscape ? (UIDevice.current.name == "iPhone SE (2nd generation)" ? 20 : 100) : 25)
         //   .padding(.top, UIDevice.current.orientation.isLandscape ? 20 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 35 : 50))
       */
        }
    }
}

struct Web: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView(frame: .zero)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: self.url) else {return}
        
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
