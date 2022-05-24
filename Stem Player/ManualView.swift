//
//  ManualView.swift
//  Stem Player
//
//  Created by Thatcher Clough on 3/17/22.
//

import SwiftUI

struct ManualView: View {
    var completion: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentIndex.animation()) {
                ForEach(0..<3, id: \.self) { index in
                    VStack {
                        if colorScheme == .light {
                            Image("\(index)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image("\(index)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .colorInvert()
                        }
                        
                        Text(index == 0 ? "PLAY / PAUSE" : (index == 1 ? "CHANGE STEM VOLUME" : "ISOLATE STEM"))
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: geometry.size.width - 50, height: geometry.size.width - 50)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay(
                VStack {
                    Spacer()
                    PageDots(numberOfPages: 3, currentIndex: currentIndex)
                }
            )
            .frame(width: geometry.size.width - 50, height: geometry.size.width + 10)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct PageDots: View {
    @Environment(\.colorScheme) var colorScheme
    
    let numberOfPages: Int
    let currentIndex: Int
    
    @State private var primaryColor = Color.white
    @State private var secondaryColor = Color.white.opacity(0.3)
    
    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<numberOfPages) { index in
                Circle()
                    .fill(currentIndex == index ? primaryColor : secondaryColor)
                    .frame(width: 8, height: 8)
                    .transition(AnyTransition.opacity)
                    .id(index)
            }
        }
        .onAppear(perform: {
            primaryColor = colorScheme == .dark ? Color.white : Color.black
            secondaryColor = primaryColor.opacity(0.3)
        })
        .onChange(of: colorScheme) { colorScheme in
            primaryColor = colorScheme == .dark ? Color.white : Color.black
            secondaryColor = primaryColor.opacity(0.3)
        }
    }
}
