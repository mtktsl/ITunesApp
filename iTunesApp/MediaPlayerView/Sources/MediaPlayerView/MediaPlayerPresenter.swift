//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.06.2023.
//

import Foundation
import AVFoundation

extension MediaPlayerPresenter {
    fileprivate enum Animation {
        static let fadeOutDuration: Double = 4.0
    }
}

protocol MediaPlayerPresenterProtocol: AnyObject {
    
    func onInit()
    
    func onBoundsChange()
    
    func onViewTap()
    func onRewindTap()
    func onPlayTap()
    func onForwardTap()
}

final class MediaPlayerPresenter {
    
    unowned var view: MediaPlayerViewProtocol!
    var interactor: MediaPlayerInteractorProtocol!
    
    var isFilterOpen = false
    
    var fadeOutWork: DispatchWorkItem?
    
    init(
        view: MediaPlayerViewProtocol,
        interactor: MediaPlayerInteractorProtocol
    ) {
        self.view = view
        self.interactor = interactor
    }
}

extension MediaPlayerPresenter: MediaPlayerPresenterProtocol {
    func onBoundsChange() {
        view.layoutMediaLayers()
    }
    
    func onViewTap() {
        fadeOutWork?.cancel()
        
        if isFilterOpen {
            view.fadeOut()
            isFilterOpen = false
            return
        }
        
        view.fadeIn()
        isFilterOpen = true
        
        fadeOutWork = DispatchWorkItem(block: { [weak self] in
            guard let self else { return }
            view.fadeOut()
            isFilterOpen = false
        })
        
        guard let fadeOutWork else { return }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Animation.fadeOutDuration,
            execute: fadeOutWork
        )
    }
    
    func onInit() {
        view.setupSubviews()
        view.setupGesture()
        onViewTap()
        view.layoutMediaLayers()
        onPlayTap()
    }
    
    func onRewindTap() {
        interactor.seekPlayer(direction: .backward)
    }
    
    func onPlayTap() {
        interactor.togglePlay()
    }
    
    func onForwardTap() {
        interactor.seekPlayer(direction: .forward)
    }
}

extension MediaPlayerPresenter: MediaPlayerInteractorOutputProtocol {
    
    func onPlayerStatusChanged(_ status: AVPlayer.TimeControlStatus) {
        switch status {
        case .playing:
            view.showPause()
        default:
            view.showPlay()
        }
        isFilterOpen = false
        onViewTap()
    }
    
    func onPlayerSeek(_ result: PlayerJumpResult) {
        switch result {
        case .begin:
            view.showPause()
            isFilterOpen = false
            onViewTap()
        case .inRange:
            view.showPause()
            isFilterOpen = false
            onViewTap()
        case .end:
            view.showPlay()
        }
    }
    
    func onPlayerDidFinish() {
        view.showPlay()
        fadeOutWork?.cancel()
        view.fadeIn()
        isFilterOpen = true
    }
    
    func onPlayerProgress(current: Int, remaining: Int, progress: Float) {
        
        let currentText = interactor.secondsToMinutes(current)
        let remainingText = "-\(interactor.secondsToMinutes(remaining))"
        
        view.setProgressBar(
            currentText: currentText,
            remainingText: remainingText,
            progress: progress
        )
    }
    
    func onPlayerSet(_ layer: AVPlayerLayer) {
        view.setupPlayerLayer(layer)
    }
}
