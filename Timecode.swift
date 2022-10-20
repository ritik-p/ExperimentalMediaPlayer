//
//  Timecode.swift
//  MediaApp
//
//

import Foundation
import CoreMedia

struct Timecode {
        var hours: Int
        var minutes: Int
        var seconds: Int
        var frames: Int
    
    
    var display: String {
        let formatter = NumberFormatter()
        formatter.maximumIntegerDigits = 2
        formatter.minimumIntegerDigits = 2
        formatter.maximumFractionDigits = 0
        
        guard let h = formatter.string(from: NSNumber(value: hours)) else { return "--:--:--:--" }
        guard let m = formatter.string(from: NSNumber(value: minutes)) else { return "--:--:--:--" }
        guard let s = formatter.string(from: NSNumber(value: seconds)) else { return "--:--:--:--" }
        guard let f = formatter.string(from: NSNumber(value: frames)) else { return "--:--:--:--" }
        
        return "\(h):\(m):\(s):\(f)"
    }
    
    
    init(time: CMTime, rate: Float) {
        let fseconds = time.seconds
        let iseconds = Int(fseconds)
        hours = iseconds / 3600
        let remainingSeconds = iseconds % 3600
        minutes = remainingSeconds / 60
        seconds = remainingSeconds % 60
        let frac = Float(fseconds) - Float(iseconds)
        frames = Int((frac * rate).rounded())
    }
    
    
}
