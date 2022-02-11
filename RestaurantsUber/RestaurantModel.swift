//
//  RestaurantModel.swift
//  RestaurantsUber
//
//  Created by Edwin Uber on 2/7/22.
//

import Foundation

struct RestaurantModel: Identifiable, Decodable {
    var id: String { place_id }

    var business_status: String
    var geometry: Geo?
    var icon: String
    var name: String
    var opening_hours: OpeningHours?
    var place_id: String
    var price_level: Int?
    var rating: Float?
    var user_ratings_total: Int?
    var reference: String
    
    
    struct Geo: Decodable {
        var location: Location
    }
    struct Location: Decodable {
        var lat: Float
        var lng: Float
    }
    
    struct OpeningHours: Decodable {
        var open_now: Bool
    }
}
