//
//  StemPlayer.swift
//  Stem Player 1
//
//  Created by Thatcher Clough on 2/26/22.
//

import SwiftUI
import AVFoundation

// Chosing files on mac
// Add spacial audio support
// Editing tracks
// Color wheel button press animation
// Issues with chosing from google drive
// Make it clear that is does not split stems

struct ContentView: View {
    
    @State var showAddSong: Bool = false
    @State var showLibrary: Bool = false
    @State var showInfo: Bool = false
    @State var showStemPlayer: Bool = true
    
    @State var stemPlayerView: StemPlayerView?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if (showStemPlayer && stemPlayerView != nil) {
                    stemPlayerView
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                } else  if (showAddSong) {
                    AddSongView(completion: { track in
                        if (track == nil) {
                            showAddSong = false
                        } else {
                            storeTrack(track: track!)
                            stemPlayerView = StemPlayerView(track: track!) {
                                showStemPlayer = false
                            }
                            showStemPlayer = true
                            showAddSong = false
                        }
                    })
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                } else if (showLibrary) {
                    LibraryView(tracks: Shared.instance.savedTracks, completion: { track in
                        if (track != nil) {
                            stemPlayerView = StemPlayerView(track: track!) {
                                showStemPlayer = false
                            }
                            showStemPlayer = true
                        } else {
                            self.showLibrary = false
                        }
                    })
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                } else if (showInfo) {
                    InfoView(completion: {
                        showInfo = false
                    })
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                } else {
                    VStack {
                        Spacer()
                        
                        Text("STEM PLAYER")
                            .font(.custom("HelveticaNeue-CondensedBold", size: 45))
                            .padding(.vertical, 10)
                        
                        Spacer()
                        
                        VStack {
                            Button {
                                showAddSong = true
                            } label: {
                                Text("[ ADD SONG ]")
                                    .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                    .foregroundColor(Color(UIColor.label))
                            }
                            .padding(2.5)
                            
                            Button {
                                showLibrary = true
                            } label: {
                                Text("[ SONG LIBRARY ]")
                                    .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                    .foregroundColor(Color(UIColor.label))
                            }
                            .padding(2.5)
                        }
                        .padding(.bottom, geometry.size.height * 0.05)
                        
                        Button {
                            showInfo = true
                        } label: {
                            Text("[ MORE INFO ]")
                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                .foregroundColor(Color(UIColor.label))
                        }
                        .padding(2.5)
                        
                        Spacer()
                        Spacer()
                    }
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                    .zIndex(1)
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    func storeTrack(track: Track) {
        var savedTracks = Shared.instance.savedTracks
        savedTracks.append(track)
        Shared.instance.savedTracks = savedTracks.sorted(by: { $0.title < $1.title} )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
