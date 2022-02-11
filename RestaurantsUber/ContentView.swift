//
//  ContentView.swift
//  RestaurantsUber
//
//  Created by Edwin Uber on 2/7/22.
//

import SwiftUI
import MapKit

struct Marker: Identifiable {
    let id = UUID()
    var location: MapAnnotation<PlaceAnnotationView>
    var restaurant: RestaurantModel
}

struct ContentView: View {
    @ObservedObject var locationModel = LocationModel()
    @State private var showMap = false
    @State var region: MKCoordinateRegion = MKCoordinateRegion()

    var markers : [Marker] {
        let markers = self.locationModel.restaurantsList.map { restaurant -> Marker in
            let latDegrees = CLLocationDegrees(restaurant.geometry?.location.lat ?? 0)
            let lngDegress = CLLocationDegrees(restaurant.geometry?.location.lng ?? 0)
            let coordinates = CLLocationCoordinate2D(latitude: latDegrees, longitude: lngDegress)
            return Marker(location: MapAnnotation<PlaceAnnotationView>(coordinate: coordinates, content: {
                PlaceAnnotationView(restaurant: restaurant)
            }), restaurant: restaurant)
        }
        return markers
    }
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    
    init() {
        locationModel.requestAuthorisation()
    }
    
    var body: some View {
        ZStack {
            VStack {
                if sizeClass == .compact {
                    ImageHeader()
                        .background(Color.white)
                        .padding(.all, 16)
                    HStack {
                        FilterButton()
                        SearchBar(searchFunction: locationModel.getRestaurants)
                            .actionSheet(isPresented: $locationModel.showLocationError) {
                                ActionSheet(
                                    title: Text("Location Services Error"),
                                    message: Text("Unable to find your location. Please ensure Location Services are turned on in Settings"),
                                    buttons: [
                                        .default(Text("Try Again")) {
                                            locationModel.showLocationError = false
                                        }
                                    ]
                                )
                            }
                    }
                } else {
                    HStack {
                        ImageHeader()
                            .background(Color.white)
                            .padding(.all, 16)
                        HStack {
                            FilterButton()
                            SearchBar(searchFunction: locationModel.getRestaurants)
                                .actionSheet(isPresented: $locationModel.showLocationError) {
                                    ActionSheet(
                                        title: Text("Location Services Error"),
                                        message: Text("Unable to find your location. Please ensure Location Services are turned on in Settings"),
                                        buttons: [
                                            .default(Text("Try Again")) {
                                                locationModel.showLocationError = false
                                            }
                                        ]
                                    )
                                }
                        }
                    }
                }
                if sizeClass == .compact {
                    if showMap {
                        Map(coordinateRegion: $locationModel.region,
                            showsUserLocation: true,
                            annotationItems: markers) { marker in
                            marker.location
                        }
                            .ignoresSafeArea()
                    } else {
                        List {
                            ForEach(self.locationModel.restaurantsList, id: \.place_id) { restaurant in
                                ListItem(restaurant: restaurant)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.all, 16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .clipped()
                                    .listRowSeparator(.hidden)
                            }
                            .listRowBackground(Color.clear)
                            .refreshable {
                                locationModel.getRestaurants()
                            }
                        }
                        .background(Color.gray)
                    }
                } else {
                    HStack {
                        List {
                            ForEach(self.locationModel.restaurantsList, id: \.place_id) { restaurant in
                                ListItem(restaurant: restaurant)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.all, 16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .clipped()
                                    .listRowSeparator(.hidden)
                            }
                            .listRowBackground(Color.clear)
                            .refreshable {
                                locationModel.getRestaurants()
                            }
                        }
                        .background(Color.gray)
                        .frame(width: 400)
                        Map(coordinateRegion: $locationModel.region,
                            showsUserLocation: true,
                            annotationItems: markers) { marker in
                            marker.location
                        }
                            .ignoresSafeArea()
                    }
                }
            }
            if sizeClass == .compact {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showMap.toggle()
                        }, label: {
                            if showMap {
                                Text("List")
                                    .font(.system(.title))
                                    .frame(width: 100, height: 42)
                                    .foregroundColor(Color.white)
                            } else {
                                Text("Map")
                                    .font(.system(.title))
                                    .frame(width: 100, height: 42)
                                    .foregroundColor(Color.white)
                            }
                            
                        })
                            .background(Color.init(red: 0.26, green: 0.54, blue: 0.07))
                            .cornerRadius(8)
                            .padding()
                            .shadow(color: Color.black.opacity(0.3),
                                    radius: 3,
                                    x: 3,
                                    y: 3)
                        Spacer()
                    }
                }
            }
        }
    }
}

//  Header / Top section
struct ImageHeader: View {
    var body: some View {
        HStack {
            Image("AllTrailsAtLunch")
                .resizable()
                .scaledToFit()
                .frame(width: 375.0, height: 30.0, alignment: .center)
        }
    }
}

struct FilterButton: View {
    var body: some View {
        Button(action: {
        }, label: {
            Text("Filter")
                .font(.system(.body))
                .frame(width: 52, height: 24)
                .foregroundColor(Color.gray)
        })
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .background(Color.white)
            .cornerRadius(8)
            .clipped()
    }
}

struct SearchBar: View {
    @State private var searchString: String = ""
    var searchFunction: (String?) -> ()
    
    var body: some View {
        VStack {
            TextField(
                "Search for a restaurant",
                text: $searchString, onCommit: {
                    print("commit: \(searchString)")
                    self.searchFunction(searchString)
                })
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .background(Color.white)
                .cornerRadius(8)
                .clipped()
        }.padding()
    }
}

//  List Items
struct ListItem: View {
    var restaurant: RestaurantModel
    
    var titleText = "Restaurant Name"
    var starRating = "Star Rating"
    var costText = "costRating"
    var separatorText = "-"
    var supportingText = "Supporting Text"
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: restaurant.icon), scale: 2)
                .padding(.trailing, 16)
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .padding(.top, 8)
                    .font(.system(size: 18))
                    .lineLimit(nil)
                HStack {
                    if let validRating = restaurant.rating {
                        StarsView(rating: CGFloat(validRating), maxRating: 5)
                        if let userRating = restaurant.user_ratings_total {
                            Text("(" + String(userRating) + ")")
                                .foregroundColor(.gray)
                        }
                    }
                }
                HStack {
                    if restaurant.price_level == 1 {
                        Text("$")
                            .foregroundColor(.gray)
                    } else if restaurant.price_level == 2 {
                        Text("$$")
                            .foregroundColor(.gray)
                    } else if restaurant.price_level == 3 {
                        Text("$$$")
                            .foregroundColor(.gray)
                    } else if restaurant.price_level == 4 {
                        Text("$$$$")
                            .foregroundColor(.gray)
                    }
                    Text(separatorText)
                        .foregroundColor(.gray)
                    if let openHours = restaurant.opening_hours?.open_now {
                        if openHours {
                            Text("OPEN NOW")
                                .foregroundColor(.gray)
                        } else {
                            Text("CLOSED")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
}

//  Map Annotations
struct PlaceAnnotationView: View {
    var restaurant: RestaurantModel
    @State var showingInfoView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
                .overlay {
                    if showingInfoView {
                        ListItem(restaurant: restaurant)
                            .frame(width: 300, alignment: .bottom)
                            .padding(.all, 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .cornerRadius(8)
                            .background(Color.white)
                            .offset(x: 0, y: -60)
                    }
                }
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.red)
                .offset(x: 0, y: -5)
        }
        .onTapGesture(count: 1) {
            withAnimation {
                showingInfoView.toggle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

