//
//  StemPlayer.swift
//  Stem Player
//
//  Created by Thatcher Clough on 2/28/22.
//

import SwiftUI
import AVFoundation
import Combine

class Stem: ObservableObject {
    var url: URL
    var player: AVAudioPlayerNode?
    
    @Published var volume: Double = 100
    @Published var muted: Bool = false
    @Published var soloed: Bool = false
    
    init(url: URL) {
        self.url = url
    }
    
    func setPlayer(player: AVAudioPlayerNode) {
        self.player = player
    }
}

class StemPlayerViewModel: ObservableObject {
    
    var songTitle: String
    var colors: [Color] = [Color(hex: "FF2657"), Color(hex: "FF2657"), Color(hex: "FF2657"), Color(hex: "FF2657")]
    var playerCenterColror: Color = Color(hex:"C8AB89")
    var playerOuterColor: Color = Color(hex: "A7937C")
    var sliderBackgroundColor: Color = Color(hex: "BAA386")
    var playerWidth: CGFloat = 450
    
    @Published var stem1: Stem
    @Published var stem2: Stem
    @Published var stem3: Stem
    @Published var stem4: Stem
    
    @Published var engineStarting: Bool = true
    
    @Published var showError: Bool = false
    @Published var error: String = "Error"
    @Published var errorMessage: String = "An error occured"
    
    var audioEngine: AVAudioEngine = AVAudioEngine()
    var mixer: AVAudioMixerNode = AVAudioMixerNode()
    
    var lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var anyCancellable1: AnyCancellable? = nil
    var anyCancellable2: AnyCancellable? = nil
    var anyCancellable3: AnyCancellable? = nil
    var anyCancellable4: AnyCancellable? = nil
    
    init(track: Track) {
        self.songTitle = track.title
        if (track.colorHexes.count > 3) {
            self.colors = [Color(hex: track.colorHexes[0]), Color(hex: track.colorHexes[1]), Color(hex: track.colorHexes[2]), Color(hex: track.colorHexes[3])]
        }
        self.stem1 = Stem(url: .audioFilesDirectory.appendingPathComponent(track.stem1URL.absoluteString, isDirectory: false))
        self.stem2 = Stem(url: .audioFilesDirectory.appendingPathComponent(track.stem2URL.absoluteString, isDirectory: false))
        self.stem3 = Stem(url: .audioFilesDirectory.appendingPathComponent(track.stem3URL.absoluteString, isDirectory: false))
        self.stem4 = Stem(url: .audioFilesDirectory.appendingPathComponent(track.stem4URL.absoluteString, isDirectory: false))
        
        anyCancellable1 = stem1.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        anyCancellable2 = stem2.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        anyCancellable3 = stem3.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        anyCancellable4 = stem4.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: NSNotification.Name.AVAudioEngineConfigurationChange,
                                               object: nil
        )
    }
    
    @objc func handleInterruption() {
        pause()
        setup()
    }
    
    func setup() {
        DispatchQueue.global(qos: .background).async {
            do {
                self.audioEngine.reset()
                self.audioEngine.attach(self.mixer)
                self.audioEngine.connect(self.mixer, to: self.audioEngine.outputNode, format: nil)
                try self.audioEngine.start()
                
                self.setupStem(stem: self.stem1) { player in
                    if (player == nil || player as? Error != nil) {
                        DispatchQueue.main.async {
                            self.error = "Error loading stem 1"
                            self.errorMessage = player as? Error != nil ? (player as! Error).localizedDescription : "An error occured when loading stem 1."
                            self.showError = true
                        }
                    } else if (player as? AVAudioPlayerNode != nil) {
                        self.stem1.player = player! as? AVAudioPlayerNode
                    }
                }
                self.setupStem(stem: self.stem2) { player in
                    if (player == nil || player as? Error != nil) {
                        DispatchQueue.main.async {
                            self.error = "Error loading stem 2"
                            self.errorMessage = player as? Error != nil ? (player as! Error).localizedDescription : "An error occured when loading stem 2."
                            self.showError = true
                        }
                    } else if (player as? AVAudioPlayerNode != nil) {
                        self.stem2.player = player! as? AVAudioPlayerNode
                    }
                }
                self.setupStem(stem: self.stem3) { player in
                    if (player == nil || player as? Error != nil) {
                        DispatchQueue.main.async {
                            self.error = "Error loading stem 3"
                            self.errorMessage = player as? Error != nil ? (player as! Error).localizedDescription : "An error occured when loading stem 3."
                            self.showError = true
                        }
                    } else if (player as? AVAudioPlayerNode != nil) {
                        self.stem3.player = player! as? AVAudioPlayerNode
                    }
                }
                self.setupStem(stem: self.stem4) { player in
                    if (player == nil || player as? Error != nil) {
                        DispatchQueue.main.async {
                            self.error = "Error loading stem 4"
                            self.errorMessage = player as? Error != nil ? (player as! Error).localizedDescription : "An error occured when loading stem 4."
                            self.showError = true
                        }
                    } else if (player as? AVAudioPlayerNode != nil) {
                        self.stem4.player = player! as? AVAudioPlayerNode
                    }
                }
                
                DispatchQueue.main.async {
                    self.engineStarting = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.engineStarting = false
                    self.error = "Audio engine error"
                    self.errorMessage = "An error occured when setting up the audio engine."
                    self.showError = true
                }
            }
        }
    }
    
    func setupStem(stem: Stem, completion: @escaping (Any?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                if (!self.audioEngine.isRunning) {
                    return completion(nil)
                }
                
                let player = AVAudioPlayerNode()
                self.audioEngine.attach(player)
                self.audioEngine.connect(player, to: self.mixer, format: nil)
                
                let fileURL = stem.url
                let file : AVAudioFile = try AVAudioFile.init(forReading: fileURL)
                
                player.scheduleFile(file, at: nil) {
                    if (self.audioEngine.isRunning) {
                        self.setup()
                    }
                }
                return completion(player)
            } catch {
                return completion(error)
            }
        }
    }
    
    func play() {
        DispatchQueue.global(qos: .background).async {
            if (!self.audioEngine.isRunning || self.stem1.player == nil || self.stem2.player == nil || self.stem3.player == nil || self.stem4.player == nil) {
                DispatchQueue.main.async {
                    self.error = "Play error"
                    self.errorMessage = "An error occured when tryaing to play."
                    self.showError = true
                }
                return
            }
            
            let delay: Float = 1
            let outputFormat = self.stem1.player!.outputFormat(forBus: AVAudioNodeBus(0))
            let startSampleTime = AVAudioFramePosition(Double(self.stem1.player?.lastRenderTime?.sampleTime ?? AVAudioFramePosition(0.0)) + Double(delay) * outputFormat.sampleRate)
            let startTime = AVAudioTime(sampleTime: startSampleTime, atRate: outputFormat.sampleRate)
            
            self.stem1.player?.play(at: startTime)
            self.stem2.player?.play(at: startTime)
            self.stem3.player?.play(at: startTime)
            self.stem4.player?.play(at: startTime)
        }
    }
    
    func pause() {
        DispatchQueue.global(qos: .background).async {
            self.stem1.player?.pause()
            self.stem2.player?.pause()
            self.stem3.player?.pause()
            self.stem4.player?.pause()
        }
    }
    
    func changeStemVolume(stem: Stem, volume: Double) {
        stem.volume = volume
        if (!stem.muted) {
            stem.player?.volume = Float(volume / 100.0)
        }
    }
    
    func toggleMuteStem(stem: Stem, mute: Bool) {
        if (mute) {
            stem.muted = true
            stem.player?.volume = 0
        } else {
            stem.muted = false
            stem.player?.volume = Float(stem.volume / 100.0)
        }
    }
    
    func toggleSoloStem1(solo: Bool) {
        if solo {
            toggleMuteStem(stem: stem1, mute: false)
            stem1.soloed = true
            
            if (!stem2.soloed) {
                toggleMuteStem(stem: stem2, mute: true)
            }
            if (!stem3.soloed) {
                toggleMuteStem(stem: stem3, mute: true)
            }
            if (!stem4.soloed) {
                toggleMuteStem(stem: stem4, mute: true)
            }
        } else {
            stem1.soloed = false
            if(!(stem2.soloed || stem3.soloed || stem4.soloed)) {
                toggleMuteStem(stem: stem2, mute: false)
                toggleMuteStem(stem: stem3, mute: false)
                toggleMuteStem(stem: stem4, mute: false)
            } else {
                toggleMuteStem(stem: stem1, mute: true)
            }
        }
    }
    
    func toggleSoloStem2(solo: Bool) {
        if solo {
            toggleMuteStem(stem: stem2, mute: false)
            stem2.soloed = true
            
            if (!stem1.soloed) {
                toggleMuteStem(stem: stem1, mute: true)
            }
            if (!stem3.soloed) {
                toggleMuteStem(stem: stem3, mute: true)
            }
            if (!stem4.soloed) {
                toggleMuteStem(stem: stem4, mute: true)
            }
        } else {
            stem2.soloed = false
            if(!(stem1.soloed || stem3.soloed || stem4.soloed)) {
                toggleMuteStem(stem: stem1, mute: false)
                toggleMuteStem(stem: stem3, mute: false)
                toggleMuteStem(stem: stem4, mute: false)
            } else {
                toggleMuteStem(stem: stem2, mute: true)
            }
        }
    }
    
    func toggleSoloStem3(solo: Bool) {
        if solo {
            toggleMuteStem(stem: stem3, mute: false)
            stem3.soloed = true
            
            if (!stem1.soloed) {
                toggleMuteStem(stem: stem1, mute: true)
            }
            if (!stem2.soloed) {
                toggleMuteStem(stem: stem2, mute: true)
            }
            if (!stem4.soloed) {
                toggleMuteStem(stem: stem4, mute: true)
            }
        } else {
            stem3.soloed = false
            if(!(stem1.soloed || stem2.soloed || stem4.soloed)) {
                toggleMuteStem(stem: stem1, mute: false)
                toggleMuteStem(stem: stem2, mute: false)
                toggleMuteStem(stem: stem4, mute: false)
            } else {
                toggleMuteStem(stem: stem3, mute: true)
            }
        }
    }
    
    func toggleSoloStem4(solo: Bool) {
        if solo {
            toggleMuteStem(stem: stem4, mute: false)
            stem4.soloed = true
            
            if (!stem1.soloed) {
                toggleMuteStem(stem: stem1, mute: true)
            }
            if (!stem2.soloed) {
                toggleMuteStem(stem: stem2, mute: true)
            }
            if (!stem3.soloed) {
                toggleMuteStem(stem: stem3, mute: true)
            }
        } else {
            stem4.soloed = false
            if(!(stem1.soloed || stem2.soloed || stem3.soloed)) {
                toggleMuteStem(stem: stem1, mute: false)
                toggleMuteStem(stem: stem2, mute: false)
                toggleMuteStem(stem: stem3, mute: false)
            } else {
                toggleMuteStem(stem: stem4, mute: true)
            }
        }
    }
}

struct StemPlayerView: View {
    var completion: () -> Void
    
    @ObservedObject var stemPlayerViewModel: StemPlayerViewModel
    
    init(track: Track, completion: @escaping () -> Void) {
        self.completion = completion
        stemPlayerViewModel = StemPlayerViewModel(track: track)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                
                Text(stemPlayerViewModel.songTitle)
                    .font(.custom("HelveticaNeue-CondensedBold", size: 45))
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width - 50)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                    .zIndex(1)
                
                Spacer()
                
                if (stemPlayerViewModel.engineStarting) {
                    Text("Starting...")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 45))
                        .multilineTextAlignment(.center)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(gradient: Gradient(colors: [stemPlayerViewModel.playerCenterColror, stemPlayerViewModel.playerOuterColor]), center: .center, startRadius: (stemPlayerViewModel.playerWidth - 50) / 4 + 20, endRadius: (stemPlayerViewModel.playerWidth - 50) / 2)
                            )
                            .frame(width: stemPlayerViewModel.playerWidth - 50, height: stemPlayerViewModel.playerWidth - 50)
                        
                        ZStack {
                            VStack(spacing: 0) {
                                StemSlider(colors: stemPlayerViewModel.colors, backgroundColor: stemPlayerViewModel.sliderBackgroundColor, dimmed: $stemPlayerViewModel.stem1.muted, vertical: true) { percent in
                                    stemPlayerViewModel.changeStemVolume(stem: stemPlayerViewModel.stem1, volume: percent)
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                } sliderPressingChange: { pressed in
                                    stemPlayerViewModel.toggleSoloStem1(solo: pressed)
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                }
                                .frame(width: 65, height: (stemPlayerViewModel.playerWidth - 50) / 2 - 20)
                                .rotationEffect(.radians(.pi))

                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.clear)

                                StemSlider(colors: stemPlayerViewModel.colors, backgroundColor: stemPlayerViewModel.sliderBackgroundColor, dimmed: $stemPlayerViewModel.stem4.muted, vertical: true) { percent in
                                    stemPlayerViewModel.changeStemVolume(stem: stemPlayerViewModel.stem4, volume: percent)
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                } sliderPressingChange: { pressed in
                                    stemPlayerViewModel.toggleSoloStem4(solo: pressed)
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                }
                                .frame(width: 65, height: (stemPlayerViewModel.playerWidth - 50) / 2 - 20)
                            }

                            HStack (spacing: 0) {
                                StemSlider(colors: stemPlayerViewModel.colors, backgroundColor: stemPlayerViewModel.sliderBackgroundColor, dimmed: $stemPlayerViewModel.stem2.muted, vertical: false) { percent in
                                    stemPlayerViewModel.changeStemVolume(stem: stemPlayerViewModel.stem2, volume: percent)
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                } sliderPressingChange: { pressed in
                                    stemPlayerViewModel.toggleSoloStem2(solo: pressed)
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                }
                                .frame(width: (stemPlayerViewModel.playerWidth - 50) / 2 - 20, height: 65)
                                .rotationEffect(.radians(.pi))

                                Button {
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                    if (stemPlayerViewModel.stem1.player != nil && stemPlayerViewModel.stem1.player!.isPlaying) {
                                        stemPlayerViewModel.pause()
                                    } else {
                                        stemPlayerViewModel.play()
                                    }
                                } label: {
                                    Circle()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(stemPlayerViewModel.playerCenterColror)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                                }

                                StemSlider(colors: stemPlayerViewModel.colors, backgroundColor: stemPlayerViewModel.sliderBackgroundColor, dimmed: $stemPlayerViewModel.stem3.muted, vertical: false) { percent in
                                    stemPlayerViewModel.changeStemVolume(stem: stemPlayerViewModel.stem3, volume: percent)
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                } sliderPressingChange: { pressed in
                                    stemPlayerViewModel.toggleSoloStem3(solo: pressed)
                                    stemPlayerViewModel.lightHapticGenerator.impactOccurred()
                                }
                                .frame(width: (stemPlayerViewModel.playerWidth - 50) / 2 - 20, height: 65)
                            }
                        }
                        .frame(width: stemPlayerViewModel.playerWidth - 50, height: stemPlayerViewModel.playerWidth - 50)
                    }
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                    .zIndex(1)
                }
                
                Spacer()
                
                Button {
                    completion()
                } label: {
                    Text("[ BACK ]")
                        .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                        .foregroundColor(Color(UIColor.label))
                }
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                .zIndex(1)
                
                Spacer()
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            .onAppear {
                if (geometry.size.width < stemPlayerViewModel.playerWidth) {
                    stemPlayerViewModel.playerWidth = geometry.size.width
                }
                
                stemPlayerViewModel.setup()
            }
            .onDisappear {
                stemPlayerViewModel.audioEngine.stop()
            }
            .alert(isPresented: $stemPlayerViewModel.showError) {
                Alert(title: Text(stemPlayerViewModel.error), message: Text(stemPlayerViewModel.errorMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }
}

struct StemSlider: View {
    @State var colors: [Color]
    @State var backgroundColor: Color
    @Binding var dimmed: Bool
    @State var vertical: Bool = false
    
    var sliderPercentageChange: (Double) -> Void
    var sliderPressingChange: (Bool) -> Void
    
    @State private var percent: Double = 100
    @State private var snappingPercent: Double = 100
    @GestureState private var pressing: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            if vertical {
                ZStack {
                    Capsule()
                        .foregroundColor(backgroundColor)
                        .frame(width: geometry.size.width - 15, height: geometry.size.height * 0.8)
                    
                    VStack(alignment: .center) {
                        StemSliderLight(isOn: true, isDimmed: $dimmed, color: colors[0])
                        
                        if (percent > 25) {
                            StemSliderLight(isOn: true, isDimmed: $dimmed, color: colors[1])
                        } else {
                            StemSliderLight(isOn: false, isDimmed: $dimmed, color: colors[1])
                        }
                        
                        if (percent > 50) {
                            StemSliderLight(isOn: true, isDimmed: $dimmed, color: colors[2])
                        } else {
                            StemSliderLight(isOn: false, isDimmed: $dimmed, color: colors[2])
                        }
                        
                        if (percent > 75) {
                            StemSliderLight(isOn: true, isDimmed: $dimmed, color: colors[3])
                        } else {
                            StemSliderLight(isOn: false, isDimmed: $dimmed, color: colors[3])
                        }
                    }
                    .frame(height: geometry.size.height * 0.8)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            self.percent = (value.location.y * 0.8) - (geometry.size.height * 0.1)
                            let snappingPercent = self.percent >= 75 ? 100 : (self.percent >= 50 ? 66.66 : (self.percent >= 25 ? 33.33 : 0))
                            if (snappingPercent != self.snappingPercent) {
                                sliderPercentageChange(snappingPercent)
                            }
                            self.snappingPercent = snappingPercent
                        }))
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                        .updating($pressing) { value, state, transaction in
                            switch value {
                            case .second(true, nil): state = true
                            default: break
                            }
                        }
                )
                .onChange(of: pressing) { pressing in
                    sliderPressingChange(pressing)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            } else {
                ZStack {
                    Capsule()
                        .foregroundColor(backgroundColor)
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height - 15)
                    
                    HStack(alignment: .center) {
                        StemSliderLight(isOn: true, isDimmed: $dimmed, color: colors[0])
                        
                        if (percent > 25) {
                            StemSliderLight(isOn: true, isDimmed: $dimmed, color: colors[1])
                        } else {
                            StemSliderLight(isOn: false, isDimmed: $dimmed, color: colors[1])
                        }
                        
                        if (percent > 50) {
                            StemSliderLight(isOn: true, isDimmed: $dimmed, color: colors[2])
                        } else {
                            StemSliderLight(isOn: false, isDimmed: $dimmed, color: colors[2])
                        }
                        
                        if (percent > 75) {
                            StemSliderLight(isOn: true, isDimmed: $dimmed, color: colors[3])
                        } else {
                            StemSliderLight(isOn: false, isDimmed: $dimmed, color: colors[3])
                        }
                    }
                    .frame(width: geometry.size.width * 0.8)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
//                .highPriorityGesture(
//                    DragGesture(minimumDistance: 0)
//                        .onChanged({ value in
//                            self.percent = (value.location.x * 0.8) - (geometry.size.width * 0.1)
//                            let snappingPercent = self.percent >= 75 ? 100 : (self.percent >= 50 ? 66.66 : (self.percent >= 25 ? 33.33 : 0))
//                            if (snappingPercent != self.snappingPercent) {
//                                sliderPercentageChange(snappingPercent)
//                            }
//                            self.snappingPercent = snappingPercent
//                        }))
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            self.percent = (value.location.x * 0.8) - (geometry.size.width * 0.1)
                            let snappingPercent = self.percent >= 75 ? 100 : (self.percent >= 50 ? 66.66 : (self.percent >= 25 ? 33.33 : 0))
                            if (snappingPercent != self.snappingPercent) {
                                sliderPercentageChange(snappingPercent)
                            }
                            self.snappingPercent = snappingPercent
                        }))
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                        .updating($pressing) { value, state, transaction in
                            switch value {
                            case .second(true, nil): state = true
                            default: break
                            }
                        }
                )
                .onChange(of: pressing) { pressing in
                    sliderPressingChange(pressing)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }
}

struct StemSliderLight: View {
    @State var isOn: Bool
    @Binding var isDimmed: Bool
    @State var color: Color
    
    var body: some View {
        Circle()
            .frame(width: 17, height: 17)
            .foregroundColor(isOn ? color: .clear)
            .shadow(color: isOn ? color: .clear, radius: 7)
            .scaleEffect(isDimmed ? 0 : 1)
            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.05)))
            .animation(.easeInOut(duration: 0.1))
    }
}

struct PreviousButtonLabel: View {
    var body: some View {
        GeometryReader { geometry in
            HStack (spacing: 1){
                Text("[")
                    .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                
                ZStack {
                    HStack {
                        Triangle()
                            .frame(width: geometry.size.height, height: geometry.size.height)
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.height * (5 / 3), height: geometry.size.height)
                    
                    HStack {
                        Spacer()
                        
                        Triangle()
                            .frame(width: geometry.size.height, height: geometry.size.height)
                    }
                    .frame(width: geometry.size.height * (5 / 3), height: geometry.size.height)
                    
                }
                .frame(width: geometry.size.height * (5 / 3), height: geometry.size.height)
                .rotationEffect(.radians(.pi))
                
                Text("]")
                    .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                    .padding(.leading, geometry.size.width * 0.05)
            }
            .foregroundColor(Color(UIColor.label))
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct NextButtonLabel: View {
    var body: some View {
        GeometryReader { geometry in
            HStack (spacing: 1){
                Text("[")
                    .font(.custom("HelveticaNeue-CondensedBold", size: 25))
                    .padding(.trailing, geometry.size.width * 0.05)
                
                ZStack {
                    HStack {
                        Triangle()
                            .frame(width: geometry.size.height, height: geometry.size.height)
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.height * (5 / 3), height: geometry.size.height)
                    
                    HStack {
                        Spacer()
                        
                        Triangle()
                            .frame(width: geometry.size.height, height: geometry.size.height)
                    }
                    .frame(width: geometry.size.height * (5 / 3), height: geometry.size.height)
                    
                }
                .frame(width: geometry.size.height * (5 / 3), height: geometry.size.height)
                
                Text("]")
                    .font(.custom("HelveticaNeue-CondensedBold", size: 25))
            }
            .foregroundColor(Color(UIColor.label))
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: (rect.size.height) * (sqrt(3.0) / 2.0), y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        return path
    }
}
