//
//  LibraryView.swift
//  Stem Player
//
//  Created by Thatcher Clough on 2/28/22.
//

import SwiftUI

struct LibraryView: View {
    @State var tracks: [Track]
    
    var completion: (Track?) -> Void
    
    @State var showConfirmDelete: Bool = false
    @State var indexOfTrackToDelete: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("SONG LIBRARY")
                    .font(.custom("HelveticaNeue-CondensedBold", size: 45))
                    .padding(.top, geometry.size.height * 0.07)
                    .padding(.bottom, 5)
                
                Button {
                    completion(nil)
                } label :{
                    Text("[ BACK ]")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                        .foregroundColor(Color(UIColor.label))
                }
                .padding(.bottom, 25)
                
                if (tracks.count > 0) {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(0..<tracks.count, id: \.self) { index in
                                if (index < tracks.count) {
                                    HStack {
                                        Button {
                                            completion(tracks[index])
                                        } label: {
                                            Text(tracks[index].title)
                                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                                .foregroundColor(Color(UIColor.label))
                                        }
                                        .padding(.trailing, 5)
                                        
                                        Button {
                                            indexOfTrackToDelete = index
                                            showConfirmDelete = true
                                        } label :{
                                            Text("[ DELETE ]")
                                                .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                                                .foregroundColor(Color(UIColor.label))
                                        }
                                    }
                                    .frame(width: geometry.size.width - 50)
                                }
                            }
                            .padding(.bottom, 3)
                        }
                    }
                    .padding(.bottom, 20)
                } else {
                    Spacer()
                    
                    Text("No Songs")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                        .foregroundColor(Color(UIColor.label).opacity(0.5))
                        .offset(y: geometry.size.height * -0.1)
                    
                    Spacer()
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .alert(isPresented: $showConfirmDelete) {
                Alert(title: Text("Are you sure you want to delete \(tracks[indexOfTrackToDelete].title)"), message: Text("This will remove the song from your library."), primaryButton: Alert.Button.default(Text("No")), secondaryButton: Alert.Button.destructive(Text("Yes"), action: {
                    deleteTrack(trackIndex: indexOfTrackToDelete)
                }))
            }
        }
    }
    
    func deleteTrack(trackIndex: Int) {
        let track = tracks[trackIndex]
        tracks.remove(at: trackIndex)
        Shared.instance.savedTracks = tracks
        
        let stemsDir: URL = .audioFilesDirectory.appendingPathComponent(track.stem1URL.absoluteString, isDirectory: false).deletingLastPathComponent()
        try? FileManager.default.removeItem(at: stemsDir)
    }
}
