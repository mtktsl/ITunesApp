//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.06.2023.
//

import Foundation
import AVFoundation

extension MediaPlayerInteractor {
    fileprivate enum PlayerConstants {
        static let rewindTime: Double = 5.0
        static let forwardTime: Double = 5.0
    }
}

protocol MediaPlayerInteractorProtocol {
    func seekPlayer(
        direction: PlayerJumpDirection
    )
    
    func togglePlay()
    
    func secondsToMinutes(_ seconds: Int) -> String
}

protocol MediaPlayerInteractorOutputProtocol: AnyObject {
    func onPlayerSet(_ layer: AVPlayerLayer)
    
    func onPlayerProgress(
        current: Int,
        remaining: Int,
        progress: Float
    )
    
    func onPlayerDidFinish()
    
    func onPlayerSeek(_ result: PlayerJumpResult)
    
    func onPlayerStatusChanged(_ status: AVPlayer.TimeControlStatus)
}

final class MediaPlayerInteractor {
    
    weak var output: MediaPlayerInteractorOutputProtocol?
    
    var playerKvo: Any?
    
    var player: AVPlayer! {
        didSet {
            output?.onPlayerSet(AVPlayerLayer(player: player))
            
            playerKvo = player?.addPeriodicTimeObserver(
                forInterval: .init(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                queue: DispatchQueue.main) { [weak self] time in
                    guard let self else { return }
                    onPlayerTimeChange(Int(time.seconds))
                }
            
            NotificationCenter.default
                .addObserver(self,
                             selector: #selector(playerDidFinish),
                             name: .AVPlayerItemDidPlayToEndTime,
                             object: player.currentItem)
        }
    }
    
    func onPlayerTimeChange(_ current: Int) {
        let total = Int(player?.currentItem?.duration.seconds ?? .zero)
        
        let progress = Float(current) / Float(total)
        
        output?.onPlayerProgress(
            current: current,
            remaining: total - current,
            progress: progress
        )
    }
    
    func calculateSeekTime(_ jumpAmount: Double) -> Double {
        let currentTimeSeconds = player?.currentTime().seconds ?? 0.0
        return currentTimeSeconds + jumpAmount
    }
    
    @objc func playerDidFinish() {
        output?.onPlayerDidFinish()
    }
    
    
}

extension MediaPlayerInteractor: MediaPlayerInteractorProtocol {
    func togglePlay() {
        switch player.timeControlStatus {
        case.playing:
            player.pause()
            output?.onPlayerStatusChanged(.paused)
        default:
            if player?.currentTime() == player?.currentItem?.duration {
                player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                output?.onPlayerSeek(.begin)
            }
            player.play()
            output?.onPlayerStatusChanged(.playing)
        }
        
    }
    
    
    func seekPlayer(
        direction: PlayerJumpDirection
    ) {
        
        switch direction {
        case .backward:
            
            let timeSeconds = calculateSeekTime(-PlayerConstants.rewindTime)
            let newTime = CMTime(seconds: timeSeconds, preferredTimescale: 1000)
            
            if timeSeconds >= 0.0 {
                player?.seek(to: newTime) { [weak self] _ in
                    guard let self else { return }
                    player?.rate = 1.0
                }
                output?.onPlayerSeek(.inRange)
                output?.onPlayerStatusChanged(.playing)
            } else {
                player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
                    guard let self else { return }
                    player?.rate = 1.0 //to prevent jitter, setting the rate to 1.0 again
                }
                output?.onPlayerSeek(.begin)
                output?.onPlayerStatusChanged(.playing)
            }
            
        case .forward:
            
            let timeSeconds = calculateSeekTime(PlayerConstants.forwardTime)
            let newTime = CMTime(seconds: timeSeconds, preferredTimescale: 1000)
            
            if timeSeconds <= player?.currentItem?.duration.seconds ?? 0 {
                
                player?.seek(to: newTime) { [weak self] _ in
                    guard let self else { return }
                    player?.rate = 1.0 //to prevent jitter, setting the rate to 1.0 again
                }
                output?.onPlayerSeek(.inRange)
                output?.onPlayerStatusChanged(.playing)
            } else {
                player?.seek(to: player?.currentItem?.duration ?? .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
                    guard let self else { return }
                    player?.rate = 1.0 //to prevent jitter, setting the rate to 1.0 again
                    player.pause()
                }
                output?.onPlayerSeek(.end)
                output?.onPlayerStatusChanged(.paused)
            }
        }
    }
    
    func secondsToMinutes(_ seconds: Int) -> String {
        
        let minutes: Int = seconds / 60
        var minuteString = "\(minutes)"
        let seconds: Int = seconds % 60
        var secondString = "\(seconds)"
        
        if seconds < 10 {
            secondString = "0\(seconds)"
        }
        
        if minutes < 10 {
            minuteString = "0\(minutes)"
        }
        
        return minuteString + ":" + secondString
    }
}
