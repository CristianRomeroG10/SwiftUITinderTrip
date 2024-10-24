//
//  ContentView.swift
//  SwiftUITinderTrip
//
//  Created by Simon Ng on 17/7/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TopBarMenu()
            CardView(image: "yosemite-usa", title: "Yosmite, USA")
            Spacer(minLength: 20)
            BottomBarMenu()
        }
    }
}

#Preview {
    ContentView()
}
#Preview("TopBarMenu"){
    TopBarMenu()
}
#Preview("BottomBarMenu"){
    BottomBarMenu()
}


struct TopBarMenu: View {
    var body: some View {
        HStack {
            Image(systemName: "line.horizontal.3")
                .font(.system(size: 30))
            Spacer()
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 35))
            Spacer()
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 30))
        }
        .padding()
    }
}

struct BottomBarMenu: View {
    var body: some View {
        HStack {
            Image(systemName: "xmark")
                .font(.system(size: 30))
                .foregroundColor(.black)
            Button {
                //Book the trip
            } label: {
                Text("BOOK IT NOW")
                    .font(.system(.subheadline, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 15)
                    .background(.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            Image(systemName: "heart")
                .font(.system(size: 30))
                .foregroundStyle(.black)
        }
    }
}
