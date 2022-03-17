//
//  StemSplitter.swift
//  Stem Player
//
//  Created by Thatcher Clough on 3/16/22.
//

import Foundation


class StemSplitter: NSObject {
    
    var youtubeURL: URL
    var dir: URL
    private var vocals: URL?
    private var vocalsLocal: URL?
    private var bass: URL?
    private var bassLocal: URL?
    private var drums: URL?
    private var drumsLocal: URL?
    private var other: URL?
    private var otherLocal: URL?
    
    private var task: URLSessionDataTask?
    
    var completion: (([URL]?) -> Void)?
    
    init(youtubeURL: URL, dir: URL) {
        self.youtubeURL = youtubeURL
        self.dir = dir
    }
    
    func split() {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "34.125.71.164"
        components.path = "/api/get_stems"
        components.queryItems = [URLQueryItem(name: "url", value: youtubeURL.absoluteString)]
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        self.task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if error != nil || data == nil {
                print("we got errors")
                // also handle how to cancel
                if error != nil && error?.localizedDescription == "cancelled" {
                    return
                }
                // handle
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: String] {
                    if let error = json["error"] {
                        // handle
                        return
                    } else {
                        if let vocals = json["vocals"], let bass = json["bass"], let drums = json["drums"], let other = json["other"] {
                            if let vocalsURL = URL(string: "http://34.125.71.164" + vocals),  let bassURL = URL(string: "http://34.125.71.164" + bass),  let drumsURL = URL(string: "http://34.125.71.164" + drums),  let otherURL = URL(string: "http://34.125.71.164" + other){
                                self.vocals = vocalsURL
                                self.bass = bassURL
                                self.drums = drumsURL
                                self.other = otherURL
//                                var stems: [URL] = [vocalsURL, bassURL, drumsURL, otherURL]
                                self.waitForStems()
                            }
                        }
                    }
                } else {
                    // handle
                }
            } catch {
                // handle
                return
            }
        })
        self.task?.resume()
    }
    
    func setCompletion(completion: @escaping ([URL]?) -> Void) {
        self.completion = completion
    }
    
    var timer: Timer?
    func waitForStems() {
        print("initing timer")
        print(self.vocals)
        DispatchQueue.main.async {
            self.runCount = 0
            self.timer = Timer.scheduledTimer(
            timeInterval: 1,
                target: self,
            selector: #selector(self.checkStems),
                userInfo: nil,
                repeats: true
            )
        }
    
    }
    
    var runCount = 0
    @objc func checkStems() {
        runCount += 1
        if (runCount >= 120) {
            // throw error
            print("timed out")
            timer?.invalidate()
        }
        if (vocals != nil && vocalsLocal == nil) {
            FileDownloader.loadFileAsync(url: vocals!, dir: self.dir) { (path, error) in
                self.timer?.invalidate()
                if (error == nil) {
                    print("got file")
                    print(path)
                    self.timer?.invalidate()
                } else {
                    print("error with downloading file")
                    print(path)
                    return
                }
            }
        }
    }

}
