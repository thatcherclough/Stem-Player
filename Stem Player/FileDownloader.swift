//
//  FileDownloader.swift
//  Stem Player
//
//  Created by Thatcher Clough on 3/16/22.
//

import Foundation

class FileDownloader {
    static func loadFileAsync(url: URL, dir: URL, completion: @escaping (String?, Error?) -> Void) {
        let destinationUrl = dir.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            try? FileManager.default.removeItem(at: destinationUrl)
        }
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data {
                            try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                            completion(destinationUrl.path, error)
                        } else {
                            completion(destinationUrl.path, error)
                        }
                    }
                }
            } else {
                completion(destinationUrl.path, error)
            }
        })
        task.resume()
    }
}
