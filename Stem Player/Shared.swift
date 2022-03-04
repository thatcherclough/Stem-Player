//
//  Shared.swift
//  Stem Player
//
//  Created by Thatcher Clough on 2/28/22.
//

import Foundation

class Shared {
    static let instance = Shared()
    
    var savedTracks: [Track] {
        get {
            guard let data = try? Data(contentsOf: .savedTracks) else { return [] }
            return (try? JSONDecoder().decode([Track].self, from: data)) ?? []
        }
        set {
            try? JSONEncoder().encode(newValue).write(to: .savedTracks)
        }
    }
}

extension URL {
    static var storageDirectory: URL {
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "dev.thatcherclough.Stem-Player"
        let appSpecificDirectory = applicationSupport.appendingPathComponent(bundleID, isDirectory: true)
        try? FileManager.default.createDirectory(at: appSpecificDirectory, withIntermediateDirectories: true, attributes: nil)
        return appSpecificDirectory
    }
    
    static var savedTracks: URL {
        return storageDirectory.appendingPathComponent("savedTracks.json")
    }
    
    static var audioFilesDirectory: URL {
        let audioFilesDirectory: URL = .storageDirectory.appendingPathComponent("audioFiles", isDirectory: true)
        try? FileManager.default.createDirectory(at: audioFilesDirectory, withIntermediateDirectories: true, attributes: nil)
        return audioFilesDirectory
    }
}
