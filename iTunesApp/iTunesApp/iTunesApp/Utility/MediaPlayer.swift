//
//  AVManager.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import UIKit
import AVKit
import AVFoundation

final class MediaPlayerWeakRef {
    weak var ref: MediaPlayerDelegate?
    init(_ ref: MediaPlayerDelegate? = nil) {
        self.ref = ref
    }
}

protocol MediaPlayerDelegate: AnyObject {
    func urlError()
}

final class MediaPlayer {
    
    static let shared = MediaPlayer()
    var delegates = [MediaPlayerWeakRef]()
    
    private init() {}
    
    func play(_ urlString: String?, viewController: UIViewController) {
        guard let urlString,
              let url = URL(string: urlString)
        else {
            notifyDelegates()
            return
        }
        let playerVC = AVPlayerViewController()
        
        let player = AVPlayer(url: url)
        playerVC.player = player
        
        viewController.present(
            playerVC,
            animated: true
        ) { player.play() }
    }
    
    private func notifyDelegates() {
        for delegate in delegates {
            delegate.ref?.urlError()
        }
    }
}
