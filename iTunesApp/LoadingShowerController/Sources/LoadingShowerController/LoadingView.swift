//
//  LoadingView.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 2.06.2023.
//

import UIKit

class LoadingView {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    static let shared = LoadingView()
    var blurView: UIVisualEffectView = UIVisualEffectView()
    
    private init() {
        configure()
    }
    
    func configure() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        //Target of this package is IOS v12 so we have to use "whiteLarge" instead of "large"
        activityIndicator.style = .whiteLarge
        blurView.contentView.addSubview(activityIndicator)
        blurView.layer.masksToBounds = true
    }
    
    func startLoading() {
        guard let mainWindow = UIApplication.shared.windows.first else { return }
        blurView.frame = UIWindow(frame: UIScreen.main.bounds).frame
        activityIndicator.center = blurView.center
        mainWindow.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
    }
    
    func startLoading(_ frame: CGRect, cornerRadius: CGFloat) {
        guard let mainWindow = UIApplication.shared.windows.first else { return }
        blurView.frame = frame
        blurView.layer.cornerRadius = cornerRadius
        activityIndicator.center = CGPoint(
            x: frame.size.width / 2,
            y: frame.size.height / 2
        )
        mainWindow.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.blurView.removeFromSuperview()
            self.activityIndicator.stopAnimating()
        }
    }
}
