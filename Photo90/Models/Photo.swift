//
//  Photo.swift
//  Photo90
//
//  Created by Nazildo Souza on 05/06/20.
//  Copyright © 2020 Nazildo Souza. All rights reserved.
//

import SwiftUI

struct Photo: Hashable, Decodable, Identifiable {
    
    var id: String
    var urls: [String: String]
    var created_at: Date?
    var color: String
    var description: String?
    var alt_description: String?
    var links: [String: String]
    var location: Location?
    var views, downloads, likes: Int?
    var user: User
    
    struct User: Hashable, Decodable {
        var name: String?
        var profile_image: [String: String]?
        var portfolio_url: String?
    }

    struct Location: Hashable, Decodable {
        var title, name, city, country: String?
        var position: Position

        struct Position: Hashable, Decodable {
            var latitude, longitude: Double?
        }
    }
    
    var formattedDate: String {
        if let launchDate = created_at {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: launchDate)
        } else {
            return "N/C"
        }
    }
       
}

struct SearchPhoto: Hashable, Decodable {
    var results: [Photo]
}

struct ExpandImage: Hashable, Identifiable {
    var id: String
    var expand: Bool
}

