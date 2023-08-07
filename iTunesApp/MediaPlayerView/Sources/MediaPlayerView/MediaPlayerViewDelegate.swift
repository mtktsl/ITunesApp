//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.06.2023.
//

import Foundation

public protocol MediaPlayerViewDelegate: AnyObject {
    func onPipTap(_ mediaPlayerView: MediaPlayerView)
    func onCloseTap(_ mediaPlayerView: MediaPlayerView)
}
