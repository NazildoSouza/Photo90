//
//  ContentView.swift
//  Photo90
//
//  Created by Nazildo Souza on 05/06/20.
//  Copyright © 2020 Nazildo Souza. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @ObservedObject var getData = GetData()
    @State private var showSearch = false
    @State private var hero = false
    @State private var saveImage = false
    @State private var dragAmount = CGSize.zero
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            if self.getData.statusCode != 200 {
                Loading()

            } else {
                VStack {
                    if !self.getData.expand.isEmpty && !self.getData.images.isEmpty && self.getData.statusCode == 200 {
                        GeometryReader { geo in
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                HStack {
                                    Text("Photo90")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                .padding([.top, .horizontal], 30)
                                

                                ForEach(0..<self.getData.images.count) { j in
                                    
                                    GeometryReader { g in

                                        ZStack {
                                            Shimmer()

                                        
                                        CardView(data: self.$getData.images[j], expand: self.$getData.expand[j].expand, hero: self.$hero, indexWeb: self.$getData.indexWeb, showWeb: self.$getData.showWeb, saveImage: self.$saveImage)
                                            .offset(y: self.getData.expand[j].expand ? -g.frame(in: .global).minY : 0)
                                            .opacity(self.hero ? (self.getData.expand[j].expand ? 1 : 0) : 1)
                                            .onTapGesture {
                                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)){
                                                    if !self.getData.expand[j].expand{
                                                        self.getData.indexSet = j
                                                        
                                                        // opening only one time then close button will work...
                                                        self.getData.expand[j].expand.toggle()
                                                        self.hero.toggle()
                                                    }
                                                }
                                        }
                              //          .opacity(self.getData.shimmer ? 0 : 1)
                                            
                                        }
                                        
                                    }
                                    .frame(height: self.getData.expand[j].expand ? UIScreen.main.bounds.height : (UIDevice.current.userInterfaceIdiom == .pad ? 400 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 150 : 250)))
                                        
                                    .simultaneousGesture(DragGesture(minimumDistance: self.getData.expand[j].expand ? 0 : 500)
                                    .onChanged { self.dragAmount = $0.translation }
                                    .onEnded { value in
                                        if self.dragAmount.height > 150 {
                                            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)){
                                                
                                                self.getData.expand[j].expand.toggle()
                                                self.hero.toggle()
                                                self.dragAmount = .zero
                                                
                                            }
                                        } else {
                                            self.dragAmount = .zero
                                        }
                                        
                                        }
                                    )
                                    
                                }
                          //      }
                                
                                HStack {
                                    if self.getData.isSearching {
                                        Text("Página: \(self.getData.page)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            self.getData.statusCode = 0
                                            self.getData.page += 1
                                            self.getData.shimmer = true
                                            self.getData.loadSearch()
                                        }) {
                                            Text("Próximo")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                        }
                                    } else {
                                        Spacer()
                                        
                                        Button(action: {
                                            self.getData.statusCode = 0
                                            self.showSearch = false
                                            self.getData.shimmer = true
                                            self.getData.loadData()
                                        }) {
                                            Text("Próximo")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 35)
                            }
                        }
                        
                    } else {
                        GeometryReader { g in
                            Text("Sem Resultados.")
                                .font(.headline)
                        }
                    }
                }
                
                Search(getData: self.getData, search: self.$getData.search, showSearch: self.$showSearch)
                    .padding(.top, 15)
                    .padding(.horizontal, 30)
                    //  .offset(y: UIDevice.current.userInterfaceIdiom == .pad ? 65 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 45 : 55))
                    .opacity(self.hero ? 0 : 1)
                
            }
        }
        .sheet(isPresented: self.$getData.showWeb) {
            WebView(getData: self.getData, photo: self.getData.images[self.getData.indexSet])
        }
        .actionSheet(isPresented: self.$saveImage) {
            ActionSheet(title: Text("Salvar Imagem"), message: Text("Deseja salvar a imagem em sua biblioteca ?"), buttons: [.default(Text("Salvar")) { SDWebImageDownloader().downloadImage(with: URL(string: self.getData.images[self.getData.indexSet].urls["small"]!)) { (image, _, _, _) in
                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                } }, .cancel(Text("Cancelar"))])
        }
            
        .alert(isPresented: self.$getData.alert) {
            Alert(title: Text("Erro"), message: Text(self.getData.msgError), dismissButton: .default(Text("Ok")) { self.getData.loadData() })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Loading: View {
    
    var body: some View {
        ZStack {
            Blur(style: .systemUltraThinMaterial)
            
            VStack {
                Indicator()
                Text("Aguarde")
                    .padding(.top, 8)
            }
            
        }
        .frame(width: 110, height: 110)
        .cornerRadius(15)
    }
}

struct CardView : View {
    
    @Binding var data : Photo
    @Binding var expand : Bool
    @Binding var hero: Bool
    @Binding var indexWeb: Int
    @Binding var showWeb: Bool
    @Binding var saveImage: Bool
    
    var body: some View{
        GeometryReader { geo in
            // going to implement close button...
            
            ZStack(alignment: .topTrailing) {
                if self.expand {
                    AnimatedImage(url: URL(string: self.data.urls["thumb"]!))
                        .resizable()
                        .overlay(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.clear, Color.black, Color.black]), startPoint: .top, endPoint: .bottom))
                  //      .animation(.easeIn)
                    
                    Blur(style: .systemMaterial).edgesIgnoringSafeArea(.all)
                  //     .animation(nil)
                }
                
                VStack {
                    ZStack(alignment: .bottomTrailing) {
                        AnimatedImage(url: URL(string: self.data.urls["small"]!))
                            .resizable()
                            .scaledToFill()
                            .frame(height: self.expand ? (UIDevice.current.userInterfaceIdiom == .pad ? 550 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 250 : 350)) : (UIDevice.current.userInterfaceIdiom == .pad ? 400 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 150 : 250)))
                            .cornerRadius(self.expand ? 0 : 10)
                        
                        Text(self.expand ? self.data.formattedDate : (self.data.user.name ?? "Desconhecido"))
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Blur(style: .systemMaterialDark))
                            .cornerRadius(10)
                            .padding([.trailing, .bottom], 10)
                            //    .opacity(self.expand ? 0 : 1)
                            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.5 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 0.9 : 1))
                            .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
                    }
                    .padding(.horizontal, self.expand ? 0 : 20)
                    
                    if self.expand {
                        
                        HStack{
                            AnimatedImage(url: URL(string: self.data.user.profile_image!["small"] ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 0.5))
                                .shadow(radius: 8)
                            
                            Text(self.data.user.name ?? "Desconhecido")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding([.horizontal, .top])
                        
                        Text("\(self.data.description ?? "")\n\(self.data.alt_description ?? "")")
                            .padding([.top, .horizontal])
                            .layoutPriority(1)
                        
                        Spacer(minLength: 10)
                        
                        HStack{
                            
                            Text("Detalhes")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding([.horizontal, .bottom])
                        
                        HStack(spacing: 0){
                            
                            Button(action: {
                                print(self.data.user.portfolio_url ?? "sem site")
                                self.indexWeb = 1
                                self.showWeb.toggle()
                            }) {
                                
                                Image(systemName: "person")
                                    .padding(.all)
                                    .background(Blur(style: .systemChromeMaterial))
                                    .cornerRadius(5)
                                    .shadow(radius: 5)
                                    .frame(width: UIScreen.main.bounds.width / 4)
                            }
                            
                            Spacer(minLength: 0)
                            
                            Button(action: {
                                if UIDevice.current.userInterfaceIdiom == .phone {
                                let shared = UIActivityViewController(activityItems: [self.data.links["html"] ?? self.data.user.portfolio_url ?? "sem site"], applicationActivities: nil)
                                UIApplication.shared.windows.first?.rootViewController?.present(shared, animated: true, completion: nil)
                                }
                            }) {
                                
                                Image(systemName: "square.and.arrow.up")
                                    .padding(.all)
                                    .background(Blur(style: .systemChromeMaterial))
                                    .cornerRadius(5)
                                    .shadow(radius: 5)
                                    .frame(width: UIScreen.main.bounds.width / 4)
                            }
                            
                            Spacer(minLength: 0)
                            
                            Button(action: {
                                self.indexWeb = 2
                                self.showWeb.toggle()
                            }) {
                                
                                Image(systemName: "photo")
                                    .padding(.all)
                                    .background(Blur(style: .systemChromeMaterial))
                                    .cornerRadius(5)
                                    .shadow(radius: 5)
                                    .frame(width: UIScreen.main.bounds.width / 4)
                            }
                            
                            Spacer(minLength: 0)
                            
                            Button(action: {
                                self.saveImage = true
                            }) {
                                
                                Image(systemName: "square.and.arrow.down")
                                    .padding()
                                    .background(Blur(style: .systemChromeMaterial))
                                    .cornerRadius(5)
                                    .shadow(radius: 5)
                                    .frame(width: UIScreen.main.bounds.width / 4)
                            }
                        }
                        
                        Spacer(minLength: 10)
                        
                        Button(action: {
                            print(self.data.links["html"] ?? "sem site")
                            self.indexWeb = 0
                            self.showWeb.toggle()
                        }) {
                            
                            Text("Web")
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width / 2)
                                .background(Blur(style: .systemChromeMaterial))
                                .clipShape(Capsule())
                                .shadow(radius: 5)
                        }
                        .padding(.bottom, (UIApplication.shared.windows.first?.safeAreaInsets.bottom)! + 15)
                    }
                    
                }
                    // to ignore spacer scroll....
                    .contentShape(Rectangle())
                
                // showing only when its expanded...
                
                if self.expand{
                    
                    Button(action: {
                        
                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)){
                            
                            self.expand.toggle()
                            self.hero.toggle()
                        }
                        
                    }) {
                        
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Blur(style: .systemMaterialDark))
                            .clipShape(Circle())
                        
                    }
                    .padding(.trailing, UIDevice.current.orientation.isLandscape ? (UIDevice.current.name == "iPhone SE (2nd generation)" ? 20 : 100) : 25)
                    .padding(.top, UIDevice.current.orientation.isLandscape ? 20 : (UIDevice.current.name == "iPhone SE (2nd generation)" ? 35 : 50))
                }
                
            }
        }
    }
}

struct Search: View {
    @ObservedObject var getData: GetData
    @Binding var search: String
    @Binding var showSearch: Bool
    
    var body: some View {
        
        HStack {
            if showSearch {
                Image(systemName: "magnifyingglass")
                    .padding(10)
                TextField("Busca..", text: $search)
                
                Button(action: {
                    if !self.getData.search.isEmpty {
                        self.getData.isSearching = true
                        self.getData.statusCode = 0
                        self.getData.page = 1
                        self.getData.shimmer = true
                        self.getData.loadSearch()
                    }
                }) {
                    Text("Buscar")
                }
                
                Button(action: {
                    if self.getData.isSearching {
                        self.getData.isSearching = false
                        self.getData.statusCode = 0
                        self.getData.shimmer = true
                        self.search = ""
                        withAnimation {
                            self.showSearch = false
                        }
                        self.getData.loadData()
                    } else {
                        self.search = ""
                        withAnimation {
                            self.showSearch = false
                        }
                    }
                    
                }) {
                    Image(systemName: "xmark")
                        .padding(10)
                }
                
            } else {
                Button(action: {
                    withAnimation {
                        self.showSearch.toggle()
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .imageScale(.large)
                        .padding(20)
                }
            }
        }
        .padding(showSearch ? 10 : 0)
        .background(Blur(style: .systemMaterial))
        .cornerRadius(25)
        
    }
    
}

struct Indicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let effect = UIBlurEffect(style: style)
        let view = UIVisualEffectView(effect: effect)
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

