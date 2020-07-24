//
//  GetData.swift
//  Photo90
//
//  Created by Nazildo Souza on 05/06/20.
//  Copyright © 2020 Nazildo Souza. All rights reserved.
//

import SwiftUI

class GetData: ObservableObject {
    @Published var images = [Photo]()
    @Published var expand = [ExpandImage]()
    @Published var statusCode = 0
    @Published var page = 1
    @Published var search = ""
    @Published var isSearching = false
    @Published var msgError = ""
    @Published var alert = false
    @Published var indexSet = 0
    @Published var indexWeb = 0
    @Published var showWeb = false
    @Published var shimmer = true
    
    init() {
        self.loadData()
    }
    
    let key = "wjP78ukrCmc1hwZZfLkdWYbFAlW58b4GFU0zuMEfIsw"
    
    func loadData() {
        
        let url = "https://api.unsplash.com/photos/random/?count=30&client_id=\(key)"
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
        
        let session = URLSession(configuration: configuration)
        guard let uurl = URL(string: url) else {return}
        
        session.dataTask(with: uurl) { (data, response, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                DispatchQueue.main.async {
                    self.msgError = error?.localizedDescription ?? "Erro Desconhecido"
                    self.alert = true
                }   
                return
            }
            
            guard let data = data,
                  let response = response as? HTTPURLResponse else {return}
                
            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let json = try decoder.decode([Photo].self, from: data)
                
                DispatchQueue.main.async {
                    self.expand.removeAll()
                    
                    for i in json {
                        self.expand.append(ExpandImage(id: i.id, expand: false))
                    }
                    
                    self.images = json
                    self.statusCode = response.statusCode
                    
                    print("images count: \(self.images.count)\nexpand count: \(self.expand.count)")
                    print("------------------------------------")
                }

            } catch {
                DispatchQueue.main.async {
                    self.msgError = error.localizedDescription
                    self.alert = true
                }
                
                print(error.localizedDescription, error)
            }
            
        }.resume()
    }
    
    func loadSearch() {
        
        let query = self.search.replacingOccurrences(of: " ", with: "%20")
        let url = "https://api.unsplash.com/search/photos/?page=\(self.page)&query=\(query)&client_id=\(key)"
        
        let session2 = URLSession(configuration: .default)
        
        guard let urll = URL(string: url) else { return }
        
        session2.dataTask(with: urll) { (data, response, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            
            guard let data = data,
                  let response = response as? HTTPURLResponse else {return}
            
            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let json = try decoder.decode(SearchPhoto.self, from: data)
                                    
                DispatchQueue.main.async {
                    self.expand.removeAll()
                    
                    for i in json.results {
                        self.expand.append(ExpandImage(id: i.id, expand: false))
                    }
                    
                    self.images = json.results
                    self.statusCode = response.statusCode
                    
                    print("images count: \(self.images.count)\nexpand count: \(self.expand.count)")
                    print("--------------------------------------")
                }
                
            } catch {
                print(error.localizedDescription, error)
            }
            
        }.resume()
    }
}
