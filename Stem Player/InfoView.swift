//
//  InfoView.swift
//  Stem Player
//
//  Created by Thatcher Clough on 3/3/22.
//

import SwiftUI

struct InfoView: View {
    var completion: () -> Void
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                Spacer()
                
                Text("INFORMATION")
                    .font(.custom("HelveticaNeue-CondensedBold", size: 45))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                Text("This app is in no way affiliated with KANO or YZY TECH.")
                    .multilineTextAlignment(.center)
                    .font(.custom("HelveticaNeue-CondensedBold", size: 20))
                
                Spacer()
                
                VStack {
                    Text("STEM SPLITTING RESOURCES")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                        .foregroundColor(Color(UIColor.label))
                    
                    Button {
                        openURL(URL(string: "https://ezstems.com/")!)
                    } label: {
                        Text("[ EZ STEMS - WEBSITE ]")
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .padding(2.5)
                    
                    Button {
                        openURL(URL(string: "https://github.com/facebookresearch/demucs")!)
                    } label: {
                        Text("[ DEMUCS - PROGRAM ]")
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .padding(2.5)
                }
                .padding(.bottom, geometry.size.height * 0.05)
                
                VStack {
                    Button {
                        openURL(URL(string: "https://twitter.com/thatcherclough")!)
                    } label: {
                        Text("[ @THATCHERCLOUGH ]")
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .padding(2.5)
                    
                    Button {
                        openURL(URL(string: "https://github.com/ThatcherClough/StemPlayer")!)
                    } label: {
                        Text("[ SOURCE CODE ]")
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .padding(2.5)
                }
                .padding(.bottom, geometry.size.height * 0.05)
                
                Button {
                    completion()
                } label: {
                    Text("[ BACK ]")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                        .foregroundColor(Color(UIColor.label))
                }
                .padding(2.5)
                
                Spacer()
                Spacer()
            }
            .frame(width: geometry.size.width - 50)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
