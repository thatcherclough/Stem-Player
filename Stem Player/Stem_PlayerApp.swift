//
//  Stem_PlayerApp.swift
//  Stem Player
//
//  Created by Thatcher Clough on 2/26/22.
//

import SwiftUI
import AVFoundation

@main
struct Stem_PlayerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [ .allowAirPlay])
                        try AVAudioSession.sharedInstance().setActive(true)
                        UIApplication.shared.isIdleTimerDisabled = true
                    } catch {}
                }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
