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
    
    @State var showManualView: Bool = false
    @State var showStemSplittingResources: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack {
                    Text("INFORMATION")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 45))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                    
                    Text("This app is in no way affiliated with KANO or YEEZY TECH.")
                        .multilineTextAlignment(.center)
                        .font(.custom("HelveticaNeue-CondensedBold", size: 20))
                }
                .animation(Animation.easeInOut(duration: 0.2))
                
                Spacer()
                
                if showManualView {
                    ManualView(completion: {
                        showManualView = false
                    })
                        .frame(width: geometry.size.width > 550 ? 500 : geometry.size.width - 50, height: geometry.size.width > 550 ? 550 : geometry.size.width)
                        .padding(.bottom, geometry.size.height * 0.05)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                } else if showStemSplittingResources {
                    VStack {
                        Text("RESOURCES FOR SPLITTING A SONG INTO ITS STEMS:")
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, geometry.size.height * 0.05)
                        
                        Button {
                            openURL(URL(string: "https://apps.apple.com/app/apple-store/id1515796612/")!)
                        } label: {
                            Text("[ MOISES - iOS APP ]")
                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                .foregroundColor(Color(UIColor.label))
                        }
                        .padding(2.5)
                        
                        Button {
                            openURL(URL(string: "https://audiostrip.co.uk/")!)
                        } label: {
                            Text("[ AUDIOSTRIP - WEBSITE ]")
                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                .foregroundColor(Color(UIColor.label))
                        }
                        .padding(2.5)
                        
                        Button {
                            openURL(URL(string: "https://github.com/facebookresearch/demucs")!)
                        } label: {
                            Text("[ DEMUCS - DESKTOP PROGRAM ]")
                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                .foregroundColor(Color(UIColor.label))
                        }
                        .padding(2.5)
                    }
                    .padding(.bottom, geometry.size.height * 0.05)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                    .zIndex(1)
                } else {
                    VStack {
                        Button {
                            showManualView = true
                        } label: {
                            Text("[ MANUAL ]")
                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                .foregroundColor(Color(UIColor.label))
                        }
                        .padding(2.5)
                        
                        Button {
                            showStemSplittingResources = true
                        } label: {
                            Text("[ STEM SPLITTING RESOURCES ]")
                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                .foregroundColor(Color(UIColor.label))
                        }
                        .padding(2.5)
                        .padding(.bottom, geometry.size.height * 0.05)
                        
                        Button {
                            openURL(URL(string: "https://twitter.com/thatcherclough")!)
                        } label: {
                            Text("[ @THATCHERCLOUGH ]")
                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                .foregroundColor(Color(UIColor.label))
                        }
                        .padding(2.5)
                        
                        Button {
                            openURL(URL(string: "https://github.com/ThatcherClough/Stem-Player")!)
                        } label: {
                            Text("[ SOURCE CODE ]")
                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                .foregroundColor(Color(UIColor.label))
                        }
                        .padding(2.5)
                    }
                    .padding(.bottom, geometry.size.height * 0.05)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                    .zIndex(1)
                }
                
                Button {
                    if showManualView {
                        showManualView = false
                    } else if showStemSplittingResources {
                        showStemSplittingResources = false
                    } else {
                        completion()
                    }
                } label: {
                    Text("[ BACK ]")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                        .foregroundColor(Color(UIColor.label))
                }
                .padding(2.5)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                .zIndex(1)
                .animation(Animation.easeInOut(duration: 0.2))
                
                Spacer()
                Spacer()
            }
            .frame(width: geometry.size.width - 50)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
