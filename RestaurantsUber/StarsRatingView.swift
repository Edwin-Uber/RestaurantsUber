//
//  StarsRatingView.swift
//  RestaurantsUber
//
//  Created by Edwin Uber on 2/8/22.
//

import SwiftUI

struct StarsView: View {
    var rating: CGFloat
    var maxRating: Int

    var body: some View {
        let stars = HStack(spacing: 0) {
            ForEach(0..<maxRating) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16, alignment: .center)
                    .padding(.trailing, 2)
            }
        }

        stars.overlay(
            GeometryReader { g in
                let width = rating / CGFloat(maxRating) * g.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: width, height: 16, alignment: .leading)
                        .foregroundColor(.yellow)
                }
            }
            .mask(stars)
        )
        .foregroundColor(.gray)
    }
}
