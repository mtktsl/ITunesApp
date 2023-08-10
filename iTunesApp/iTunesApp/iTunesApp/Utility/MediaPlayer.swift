//
//  AVManager.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import UIKit

import FloatingViewManager
import MediaPlayerView
import iTunesAPI // <- to get the media extension type

typealias FM = FloatingViewManager

final class MediaPlayerWeakRef {
    weak var ref: MediaPlayerDelegate?
    init(_ ref: MediaPlayerDelegate? = nil) {
        self.ref = ref
    }
}

protocol MediaPlayerDelegate: AnyObject {
    func urlError()
}

protocol MediaPlayerProtocol {
    var delegates: [MediaPlayerWeakRef] { get set }
    var floatingViewSize: CGSize { get set }
    
    func play(
        _ urlString: String?,
        playingTitle: String?,
        startUpLocation: FloatingViewManager.FloatingLocation,
        floatingSize: CGSize
    )
    func pause()
    func resume()
}

final class MediaPlayer {
    
    static let shared: MediaPlayerProtocol = MediaPlayer()
    
    var delegates = [MediaPlayerWeakRef]()
    var floatingViewSize: CGSize = .zero
    weak var mpView: MediaPlayerView?
    
    private init() {}
    
    private func isVideo(_ urlString: String) -> Bool {
        let maxCharCount = max(
            iTunesAPI.MediaInfo.audioContentExtension.count,
            iTunesAPI.MediaInfo.videoContentExtension.count
        )
        let lastChars = urlString.suffix(maxCharCount)
        
        if lastChars == iTunesAPI.MediaInfo.audioContentExtension {
            return false
        } else {
            return true
        }
    }
    
    private func notifyDelegates() {
        delegates = delegates.compactMap({ $0 })
        for delegate in delegates {
            delegate.ref?.urlError()
        }
    }
}

extension MediaPlayer: MediaPlayerViewDelegate {
    
    func onPipTap(_ mediaPlayerView: MediaPlayerView) {
        
        let isFullScreen = FM.shared.viewCurrentSize == .fullScreen
        
        mpView?.titleLabel.isHidden = isFullScreen
        mpView?.infoLabel.isHidden = isFullScreen
        
        isFullScreen
        ? FM.shared.resizeView(to: .custom(size: floatingViewSize)) {}
        : FM.shared.resizeView(to: .fullScreen) {}
    }
    
    func onCloseTap(_ mediaPlayerView: MediaPlayerView) {
        
        let isFullScreen = FM.shared.viewCurrentSize == .fullScreen
        
        mpView?.titleLabel.isHidden = isFullScreen
        mpView?.infoLabel.isHidden = isFullScreen
        
        isFullScreen
        ? FM.shared.resizeView(to: .custom(size: floatingViewSize))
            { FM.shared.removeView() }
        : FM.shared.removeView()
    }
}

extension MediaPlayer: MediaPlayerProtocol {
    func pause() {
        //TODO: implement this function //make mediaplayerView playTap public
    }
    
    func resume() {
        //TODO: implement this function //make mediaplayerView playTap public
    }
    
    func play(
        _ urlString: String?,
        playingTitle: String? = nil,
        startUpLocation: FloatingViewManager.FloatingLocation,
        floatingSize: CGSize
    ) {
        guard let urlString,
              let mpView = MediaPlayerView
                .build(urlString,
                       isVideo: isVideo(urlString),
                       playingTitle: playingTitle)
        else {
            notifyDelegates()
            return
        }
        
        mpView.layer.cornerRadius = 10
        mpView.layer.masksToBounds = true
        
        self.floatingViewSize = floatingSize
        
        FM.shared.attach(
            mpView,
            startUpLocation: startUpLocation,
            startUpSize: .custom(size: floatingViewSize)
        )
        self.mpView = nil
        
        mpView.delegate = self
        mpView.titleLabel.isHidden = true
        mpView.infoLabel.isHidden = true
        
        self.mpView = mpView
    }
    
}
