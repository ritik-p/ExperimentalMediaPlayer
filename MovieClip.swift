//
//  MovieClip.swift
//  MediaDemo
//
//  Created by Loren Olson on 10/12/22.
//

import Foundation
import AVFoundation

extension URL {
    
    func homeRelativePath() -> String {
        var components = self.pathComponents
        components.removeSubrange(0...2)
        return components.joined(separator: "/")
    }
    
}

struct MovieClip: Codable {
    var relativePath: String   // "Documents/ame-430/coolmovie.mp4"
    var url: URL {
        get {
            let homeURL = FileManager.default.homeDirectoryForCurrentUser
            let completePath = homeURL.path + "/" + relativePath
            return URL(fileURLWithPath: completePath)
        }
    }
    
    var asset: AVAsset {
        get {
            return AVAsset(url: url)
        }
    }
    
    var inTime: AMETime
    var outTime: AMETime
}

struct AMETime: Codable {
    var value: Int64
    var timescale: Int32
    
    var cmtime: CMTime {
        get {
            return CMTime(value: value, timescale: timescale)
        }
        set {
            value = newValue.value
            timescale = newValue.timescale
        }
    }
    
    init(cmtime: CMTime) {
        value = cmtime.value
        timescale = cmtime.timescale
    }
}
