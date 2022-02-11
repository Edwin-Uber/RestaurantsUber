//
//  LocationModel.swift
//  RestaurantsUber
//
//  Created by Edwin Uber on 2/7/22.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit


class LocationModel: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined
    @Published var restaurantsList = [RestaurantModel]()
    @Published var showLocationError = false
    @Published var region = MKCoordinateRegion()

    //  Defaulting it to Omaha, where I live
    var currentLat: CLLocationDegrees = 41.258652
    var currentLng: CLLocationDegrees = -95.937187

    override init() {
        super.init()
        self.locationManager.delegate = self
        locationManager.requestLocation()
    }

    public func requestAuthorisation(always: Bool = false) {
        if always {
            self.locationManager.requestAlwaysAuthorization()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorisationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currentLat, longitude: currentLng), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.currentLat = location.coordinate.latitude
            self.currentLng = location.coordinate.longitude
            getRestaurants()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle failure to get a user’s location
        showLocationError = true
    }
}

extension LocationModel {
    func getRestaurants(keywords: String? = nil) {
        //  Adding a few defaults
        let key = "AIzaSyDue_S6t9ybh_NqaeOJDkr1KC9a2ycUYuE"
        let radius = "50000"
        let type = "restaurant"
        let formattedLocation = "\(self.currentLat),\(self.currentLng)"
        
        //  Only Adding Keywords if they are passed
        var keywordsFormat = ""
        if let validKeywords = keywords,
           let encodedValidKeywords = validKeywords.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            keywordsFormat = "keyword=\(encodedValidKeywords)"
        }
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(formattedLocation)&radius=\(radius)&type=\(type)&\(keywordsFormat)&key=\(key)") else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                        guard let results = json["results"] as? [[String: Any]] else { return }
                        let resultData = try JSONSerialization.data(withJSONObject: results, options: [])
                        let decodedRestaurants = try JSONDecoder().decode([RestaurantModel].self, from: resultData)
                        self.restaurantsList = decodedRestaurants
                    } catch let jsonErr {
                        print("json error:", jsonErr)
                    }
                    
                }
            }
        }

        dataTask.resume()
    }
}
