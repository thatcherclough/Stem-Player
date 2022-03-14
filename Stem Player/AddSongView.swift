//
//  AddSongView.swift
//  Stem Player
//
//  Created by Thatcher Clough on 2/28/22.
//

import SwiftUI
import ColorPickerRing

struct AddSongView: View {
    var completion: (Track?) -> Void
    
    @State var track: Track?
    
    @State var songTitle: String = ""
    
    @State var color1 = UIColor(hexString: "6300F7")
    @State var showColor1Picker: Bool = false
    
    @State var color2 = UIColor(hexString: "003099")
    @State var showColor2Picker: Bool = false
    
    @State var stem1URL: URL?
    @State var showStem1Picker: Bool = false
    @State var stem2URL: URL?
    @State var showStem2Picker: Bool = false
    @State var stem3URL: URL?
    @State var showStem3Picker: Bool = false
    @State var stem4URL: URL?
    @State var showStem4Picker: Bool = false
    
    @State var showAlert: Bool = false
    @State var alertTitle: String = "Error"
    @State var alertMessage: String = "An error occurred."
    
    var uuid = UUID().uuidString
    
    var body: some View {
        GeometryReader { geometry in
            VStack (alignment: .center) {
                Spacer()
                Spacer()
                
                TextField("SONG TITLE", text: $songTitle)
                    .font(.custom("HelveticaNeue-CondensedBold", size: 45))
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width - 50)
                
                VStack(spacing: 0) {
                    Text("COLORS:")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 30))
                        .padding(.bottom, 5)
                    
                    HStack {
                        ZStack {
                            Button {
                                showColor1Picker.toggle()
                            } label : {
                                Circle()
                                    .foregroundColor(Color(color1))
                                    .frame(width: 40, height: 40)
                            }
                            if (showColor1Picker) {
                                ColorPickerRing(color: $color1, strokeWidth: 10)
                                    .frame(width: 70, height: 70)
                            }
                        }
                        .frame(width: 70, height: 70)
                        .padding(.trailing, 10)
                        
                        ZStack {
                            Button {
                                showColor2Picker.toggle()
                            } label : {
                                Circle()
                                    .foregroundColor(Color(color2))
                                    .frame(width: 40, height: 40)
                            }
                            if (showColor2Picker) {
                                ColorPickerRing(color: $color2, strokeWidth: 10)
                                    .frame(width: 70, height: 70)
                            }
                        }
                        .frame(width: 70, height: 70)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button {
                        showStem1Picker.toggle()
                    } label: {
                        Text(stem1URL == nil ? "[ CHOSE STEM 1 ]" : stem1URL!.lastPathComponent)
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .sheet(isPresented: $showStem1Picker) {
                        DocumentPicker() { url in
                            if (url == nil) {
                                alertTitle = "Could not chose stem"
                                alertMessage = "An error occurred when trying to chose stem."
                                showAlert = true
                            }
                            stem1URL = getPermanentStemURL(url: url!)
                        }
                        .ignoresSafeArea(.all)
                    }
                    
                    
                    Button {
                        showStem2Picker.toggle()
                    } label: {
                        Text(stem2URL == nil ? "[ CHOSE STEM 2 ]" : stem2URL!.lastPathComponent)
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .sheet(isPresented: $showStem2Picker) {
                        DocumentPicker() { url in
                            if (url == nil) {
                                alertTitle = "Could not chose stem"
                                alertMessage = "An error occurred when trying to chose stem."
                                showAlert = true
                            }
                            stem2URL = getPermanentStemURL(url: url!)
                        }
                        .ignoresSafeArea(.all)
                    }
                    
                    Button {
                        showStem3Picker.toggle()
                    } label: {
                        Text(stem3URL == nil ? "[ CHOSE STEM 3 ]" : stem3URL!.lastPathComponent)
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .sheet(isPresented: $showStem3Picker) {
                        DocumentPicker() { url in
                            if (url == nil) {
                                alertTitle = "Could not chose stem"
                                alertMessage = "An error occurred when trying to chose stem."
                                showAlert = true
                            }
                            stem3URL = getPermanentStemURL(url: url!)
                        }
                        .ignoresSafeArea(.all)
                    }
                    
                    Button {
                        showStem4Picker.toggle()
                    } label: {
                        Text(stem4URL == nil ? "[ CHOSE STEM 4 ]" : stem4URL!.lastPathComponent)
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .sheet(isPresented: $showStem4Picker) {
                        DocumentPicker() { url in
                            if (url == nil) {
                                alertTitle = "Could not chose stem"
                                alertMessage = "An error occurred when trying to chose stem."
                                showAlert = true
                            }
                            stem4URL = getPermanentStemURL(url: url!)
                        }
                        .ignoresSafeArea(.all)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        hideKeyboard()
                        
                        completion(nil)
                    } label: {
                        Text("[ CANCEL ]")
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                    
                    Button {
                        hideKeyboard()
                        
                        if (songTitle.isEmpty) {
                            alertTitle = "Chose song title"
                            alertMessage = "Chose a song title before saving."
                            showAlert = true
                        } else if (stem1URL == nil || stem2URL == nil || stem3URL == nil || stem4URL == nil) {
                            alertTitle = "Chose stems"
                            alertMessage = "Chose stems before adding."
                            showAlert = true
                        } else {
                            var color1 = self.color1
                            color1 = color1.lighter(by: 30) ?? color1
                            var color2 = self.color1.toColor(self.color2, percentage: 33)
                            color2 = color2.lighter(by: 30) ?? color2
                            var color3 = self.color1.toColor(self.color2, percentage: 66)
                            color3 = color3.lighter(by: 30) ?? color3
                            var color4 = self.color2
                            color4 = color4.lighter(by: 30) ?? color4
                            
                            let track = Track(title: songTitle, colorHexes: [color1.toHexString(), color2.toHexString(), color3.toHexString(), color4.toHexString()], stem1URL: stem1URL!, stem2URL: stem2URL!, stem3URL: stem3URL!, stem4URL: stem4URL!)
                            completion(track)
                        }
                    } label: {
                        Text("[ ADD SONG ]")
                            .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                            .foregroundColor(Color(UIColor.label))
                    }
                }
                
                Spacer()
                Spacer()
            }
            .frame(width: geometry.size.width - 50)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }
    
    func getPermanentStemURL(url: URL) -> URL? {
        let trackDirectory: URL = .audioFilesDirectory.appendingPathComponent(uuid, isDirectory: true)
        try? FileManager.default.createDirectory(at: trackDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let relativeFileCopyURL: URL = URL(string: uuid)!.appendingPathComponent(url.lastPathComponent, isDirectory: false)
        let fileCopy: URL = .audioFilesDirectory.appendingPathComponent(relativeFileCopyURL.absoluteString)
        do {
            if (FileManager.default.fileExists(atPath: fileCopy.path)) {
                try FileManager.default.removeItem(at: fileCopy)
            }
            try FileManager.default.moveItem(at: url, to: fileCopy)
            return relativeFileCopyURL
        } catch {
            return nil
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 100), 0) / 100
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }
            
            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                           green: CGFloat(g1 + (g2 - g1) * percentage),
                           blue: CGFloat(b1 + (b2 - b1) * percentage),
                           alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
