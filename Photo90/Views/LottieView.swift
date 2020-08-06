//
//  LottieView.swift
//  Photo90
//
//  Created by Nazildo Souza on 05/08/20.
//  Copyright © 2020 Nazildo Souza. All rights reserved.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var fileName = "LottieLogo2"
    
    func makeUIView(context: Context) -> AnimationView {
        let view = AnimationView()
        let animation = Animation.named(fileName)
        view.animation = animation
        view.loopMode = .repeat(.infinity)
        view.play()
        return view
    }
    
    func updateUIView(_ uiView: AnimationView, context: Context) {
        
    }
}
