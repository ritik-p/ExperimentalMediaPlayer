//
//  ViewController.swift
//  MediaDemo
//
//  Created by Loren Olson on 9/28/22.
//

import Cocoa
import AVKit

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var playerView: AVPlayerView!
    
    var playerItem: AVPlayerItem?
    var rate: Float = 1.0
    
    
    // TESTING MovieClip
    
    var clip1: MovieClip?
    var clip2: MovieClip?
    
    var clips: [MovieClip] = []
    var clipList: [String] = []
    
    
    @IBOutlet weak var endTimeLabel: NSTextField!
    
    @IBOutlet weak var clip1Label: NSTextField!
    
    @IBOutlet weak var clip2Label: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.dataSource = self
        //tableView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return clipList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tc = tableColumn, let cell = tableView.makeView(withIdentifier: tc.identifier, owner: self) as? NSTableCellView else{return nil}
    
        cell.textField?.stringValue = clipList[row]
        return cell
    }

    
    @IBAction func openDocument(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        let response = openPanel.runModal()
        if response == .OK {
            if let url = openPanel.url {
                print("User selected URL is \(url.path)")
                
                playerItem = AVPlayerItem(url: url)
                
                let player = AVPlayer(playerItem: playerItem)
                playerView.player = player
                view.window?.title = url.lastPathComponent
                
                let tableString = url.lastPathComponent
                clipList.append(tableString)
                print(clipList)
                tableView.reloadData()
                
                // Find out the video rate
                let asset = playerItem?.asset
                if let track = asset?.tracks(withMediaType: .video).first {
                    rate = track.nominalFrameRate
                    print(rate)
                }
                
                let outCMTime = asset?.duration ?? CMTime.zero
                let outTime = AMETime(cmtime: outCMTime)
                let inTime = AMETime(cmtime: CMTime.zero)
                let relativePath = url.homeRelativePath()
                
                if clip1 == nil {
                    clip1 = MovieClip(relativePath: relativePath, inTime: inTime, outTime: outTime)
                    clip1Label.stringValue = clip1?.relativePath ?? "-"
                }
                else {
                    clip2 = MovieClip(relativePath: relativePath, inTime: inTime, outTime: outTime)
                    clip2Label.stringValue = clip2?.relativePath ?? "-"
                    
                    if let clip1 = clip1, let clip2 = clip2 {
                        clips = [clip1, clip2]
                    }
                }
            }
        }
    }

    @IBAction func forwardEndTimeAction(_ sender: NSButton) {
        
        guard let playerItem = playerItem else { return }
        
        let t = playerItem.currentTime()
        
        playerItem.forwardPlaybackEndTime = t
        
        let timeCode = Timecode(time: t, rate: rate)
        endTimeLabel.stringValue = timeCode.display
        
    }
    
    // two clips have been opened.
    // create a new asset by appending clip 2 to the end of clip 1.
    @IBAction func mergeAction(_ sender: Any) {
        
        // Create a new composition with two empty tracks. (video, audio)
        let comp = AVMutableComposition()
        let trackVideo = comp.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())
        let trackAudio = comp.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        
        // insertTime will indicate where to put new content in the tracks
        var insertTime = CMTime.zero
        
        // get an AVAsset for each clip
        let asset1 = clips[0].asset
        let asset2 = clips[1].asset
        
        // get one video track, one audio track from asset 1
        let asset1VideoTracks = asset1.tracks(withMediaType: .video)
        let asset1AudioTracks = asset1.tracks(withMediaType: .audio)
        let asset1VideoTrack = asset1VideoTracks[0] as AVAssetTrack
        let asset1AudioTrack = asset1AudioTracks[0] as AVAssetTrack
        
        // create a CMTimeRange for the portion of the clip we want to use
        let timeRange1 = CMTimeRange(start: clips[0].inTime.cmtime, end: clips[0].outTime.cmtime)
        
        // insert the content from clip1 into the new composition tracks
        do {
            try trackVideo?.insertTimeRange(timeRange1, of: asset1VideoTrack, at: insertTime)
            try trackAudio?.insertTimeRange(timeRange1, of: asset1AudioTrack, at: insertTime)
        }
        catch {
            print(error)
        }
        
        // increment the insertTime based on the duration of clip1 timeRange
        insertTime = insertTime + timeRange1.duration
        
        // get one video track, one audio track from asset 2
        let asset2VideoTracks = asset2.tracks(withMediaType: .video)
        let asset2AudioTracks = asset2.tracks(withMediaType: .audio)
        let asset2VideoTrack = asset2VideoTracks[0] as AVAssetTrack
        let asset2AudioTrack = asset2AudioTracks[0] as AVAssetTrack
        
        // create a CMTimeRange for the portion of the clip we want to use
        let timeRange2 = CMTimeRange(start: clips[1].inTime.cmtime, end: clips[1].outTime.cmtime)
        
        // insert the content from clip2 into the new composition tracks
        do {
            try trackVideo?.insertTimeRange(timeRange2, of: asset2VideoTrack, at: insertTime)
            try trackAudio?.insertTimeRange(timeRange2, of: asset2AudioTrack, at: insertTime)
        }
        catch {
            print(error)
        }
        
        // create a playable asset from the new composition
        // set the AVPlayerView to play this playable asset
        let compostion = comp.copy() as! AVComposition
        let playerItem = AVPlayerItem(asset: compostion)
        let player = AVPlayer(playerItem: playerItem)
        playerView.player = player
        
        // Hit play
        player.play()
        
    }
    
    
    
}

