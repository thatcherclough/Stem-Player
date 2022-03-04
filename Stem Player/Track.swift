//
//  Track.swift
//  Stem Player
//
//  Created by Thatcher Clough on 2/28/22.
//

import Foundation
import UIKit

class Track: ObservableObject, Encodable, Decodable, Identifiable {
    var title: String
    var colorHexes: [String]
    var stem1URL: URL
    var stem2URL: URL
    var stem3URL: URL
    var stem4URL: URL
    var dir: String
    
    init(title: String, colorHexes: [String],   stem1URL: URL, stem2URL: URL, stem3URL: URL, stem4URL: URL) {
        self.title = title
        self.colorHexes = colorHexes
        self.stem1URL = stem1URL
        self.stem2URL = stem2URL
        self.stem3URL = stem3URL
        self.stem4URL = stem4URL
        self.dir = UUID().uuidString
    }
}
