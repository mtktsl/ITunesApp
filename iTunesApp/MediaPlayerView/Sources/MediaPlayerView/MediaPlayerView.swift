//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 27.06.2023.
//

import UIKit
import AVFoundation
import CoreImage

// ------------------ MARK: - Constants
extension MediaPlayerView {
    fileprivate enum SystemImages {
        static let rewindImage = "arrow.counterclockwise.circle"
        static let forwardImage = "arrow.clockwise.circle"
        static let playImage = "play.circle"
        static let pauseImage = "pause.circle"
        
        static let xmark = "xmark.app"
        static let pip = "pip.swap"
        static let playRectangle = "headphones.circle"//"waveform"
    }
    
    fileprivate enum Sizes {
        static let progressSize: CGFloat = 2.5
        static let timeGap: CGFloat = 5
        static let windowButtonSize: CGFloat = 25
        static let interButtonSize: CGFloat = 35
        static let interButtonMultiplier: CGFloat = 0.15
        static let edgeGap: CGFloat = 5
    }
    
    fileprivate enum Colors {
        static let interButtonColor = UIColor.white
    }
    
    fileprivate enum Animation {
        static let duration: Double = 0.35
        static let filterOpacity: Float = 0.5
        static let viewOpacity: Float = 0.8
    }
}

// ------------------ MARK: - Protocol decleration
internal protocol MediaPlayerViewProtocol: AnyObject {
    func setProgressBar(currentText: String, remainingText: String, progress: Float)
    
    func showPlay()
    func showPause()
    
    func fadeOut()
    func fadeIn()
    
    func setupSubviews()
    func setupGesture()
    
    func setupPlayerLayer(_ layer: AVPlayerLayer?)
    func layoutMediaLayers()
}

// ------------------ MARK: - Class declaration
public class MediaPlayerView: UIView {
    
    lazy var rewindButton: UIButton = {
        let rewindButton = UIButton()
        rewindButton.contentMode = .scaleAspectFit
        rewindButton.setBackgroundImage(
            UIImage(systemName: SystemImages.rewindImage),
            for: .normal
        )
        rewindButton.tintColor = Colors.interButtonColor
        
        rewindButton.addTarget(
            self,
            action: #selector(onRewindTap),
            for: .touchUpInside
        )
        rewindButton.layoutIfNeeded()
        rewindButton.subviews.first?.contentMode = .scaleAspectFit
        
        return rewindButton
    }()
    
    lazy var playButton: UIButton = {
        let playButton = UIButton()
        playButton.setBackgroundImage(
            UIImage(systemName: SystemImages.playImage),
            for: .normal
        )
        playButton.tintColor = Colors.interButtonColor
        playButton.layoutIfNeeded()
        playButton.subviews.first?.contentMode = .scaleAspectFit
        
        playButton.addTarget(
            self,
            action: #selector(onPlayTap),
            for: .touchUpInside
        )
        
        return playButton
    }()
    
    lazy var forwardButton: UIButton = {
        let forwardButton = UIButton()
        forwardButton.contentMode = .scaleAspectFit
        forwardButton.setBackgroundImage(
            UIImage(systemName: SystemImages.forwardImage),
            for: .normal
        )
        forwardButton.tintColor = Colors.interButtonColor
        
        forwardButton.addTarget(
            self,
            action: #selector(onForwardTap),
            for: .touchUpInside
        )
        
        forwardButton.layoutIfNeeded()
        forwardButton.subviews.first?.contentMode = .scaleAspectFit
        
        return forwardButton
    }()
    
    lazy var pipButton: UIButton = {
        let pipButton = UIButton()
        pipButton.contentMode = .scaleAspectFit
        pipButton.setBackgroundImage(
            UIImage(systemName: SystemImages.pip),
            for: .normal
        )
        pipButton.tintColor = Colors.interButtonColor
        pipButton.layoutIfNeeded()
        pipButton.subviews.first?.contentMode = .scaleAspectFit
        
        pipButton.addTarget(
            self,
            action: #selector(onPipTap),
            for: .touchUpInside
        )
        
        return pipButton
    }()
    
    lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.contentMode = .scaleAspectFit
        closeButton.setBackgroundImage(
            UIImage(systemName: SystemImages.xmark),
            for: .normal
        )
        closeButton.tintColor = Colors.interButtonColor
        closeButton.layoutIfNeeded()
        closeButton.subviews.first?.contentMode = .scaleAspectFit
        
        closeButton.addTarget(
            self,
            action: #selector(onCloseTap),
            for: .touchUpInside
        )
        
        return closeButton
    }()
    
    let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.trackTintColor = .gray
        progressBar.progressTintColor = .white
        return progressBar
    }()
    
    let currentTimeLabel: UILabel = {
        let currentLabel = UILabel()
        currentLabel.text = "0:00"
        currentLabel.textColor = .lightText
        return currentLabel
    }()
    
    let remainingTimeLabel: UILabel = {
        let remainingTimeLabel = UILabel()
        remainingTimeLabel.text = "0:00"
        remainingTimeLabel.textColor = .lightText
        return remainingTimeLabel
    }()
    
    public let infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.textColor = .white
        infoLabel.font = .preferredFont(forTextStyle: .title3)
        infoLabel.textAlignment = .center
        infoLabel.text = "Playing:"
        return infoLabel
    }()
    
    public let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .gray
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textAlignment = .center
        titleLabel.text = "Boulevard of Broken Dreams"
        titleLabel.numberOfLines = 2
        return titleLabel
    }()
    
    let blackFilterView: UIView = {
        let blackFilterView = UIView()
        blackFilterView.backgroundColor = .black
        blackFilterView.layer.opacity = 0.5
        blackFilterView.tag = 1
        return blackFilterView
    }()
    
    var presenter: MediaPlayerPresenterProtocol!
    
    public weak var delegate: MediaPlayerViewDelegate?
    
    var playerLayer: AVPlayerLayer?
    var musicIndicatorImageView = UIImageView(
        image: UIImage(systemName: SystemImages.playRectangle)
    )
    var isFiltered = false
    var isVideo = false
    
    var boundsObservation: NSKeyValueObservation?
    
    internal init() {
        super.init(frame: .zero)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        presenter.onInit()
    }
    
    public static func build(
        _ urlString: String,
        isVideo: Bool = false,
        playingTitle: String? = nil
    ) -> MediaPlayerView? {
        guard let url = URL(string: urlString)
        else { return nil }
        
        let player = AVPlayer(url: url)
        
        let view = MediaPlayerView()
        let interactor = MediaPlayerInteractor()
        let presenter = MediaPlayerPresenter(
            view: view,
            interactor: interactor
        )
        
        view.presenter = presenter
        interactor.output = presenter
        interactor.player = player
        
        view.titleLabel.text = playingTitle
        view.isVideo = isVideo
        
        return view
    }
}

// ------------------ MARK: - Function implementations
internal extension MediaPlayerView {
    
    @objc func onViewTap() {
        presenter.onViewTap()
    }
    
    @objc func onPlayTap() {
        presenter.onPlayTap()
    }
    
    @objc func onRewindTap() {
        presenter.onRewindTap()
    }
    
    @objc func onForwardTap() {
        presenter.onForwardTap()
    }
    
    @objc func onCloseTap() {
        delegate?.onCloseTap(self)
    }
    
    @objc func onPipTap() {
        delegate?.onPipTap(self)
    }
    
    func setupMusicIndicatorImageView() {
        
        musicIndicatorImageView.contentMode = .scaleAspectFit
        musicIndicatorImageView.tintColor = .gray
        musicIndicatorImageView.tag = -1
        
        musicIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(musicIndicatorImageView)
        
        NSLayoutConstraint.activate([
            musicIndicatorImageView.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,
                constant: Sizes.edgeGap),
            musicIndicatorImageView.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                constant: Sizes.edgeGap),
            musicIndicatorImageView.bottomAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.bottomAnchor,
                constant: -Sizes.edgeGap),
            musicIndicatorImageView.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                constant: -Sizes.edgeGap)
        ])
    }
    
    func setupFilterView() {
        blackFilterView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blackFilterView)
        
        NSLayoutConstraint.activate([
            blackFilterView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            blackFilterView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            blackFilterView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            blackFilterView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    func setupWindowButtons() {
        addSubview(closeButton)
        addSubview(pipButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        pipButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Sizes.edgeGap),
            closeButton.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: Sizes.edgeGap),
            closeButton.widthAnchor.constraint(equalToConstant: Sizes.windowButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Sizes.windowButtonSize),
            
            
            pipButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Sizes.edgeGap),
            pipButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -Sizes.edgeGap),
            pipButton.widthAnchor.constraint(equalToConstant: Sizes.windowButtonSize),
            pipButton.heightAnchor.constraint(equalToConstant: Sizes.windowButtonSize)
        ])
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,
                constant: Sizes.edgeGap
            ),
            infoLabel.leadingAnchor.constraint(
                equalTo: closeButton.trailingAnchor,
                constant: Sizes.edgeGap
            ),
            infoLabel.trailingAnchor.constraint(
                equalTo: pipButton.leadingAnchor,
                constant: -Sizes.edgeGap)
        ])
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: infoLabel.bottomAnchor,
                constant: Sizes.edgeGap
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                constant: Sizes.edgeGap
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                constant: -Sizes.edgeGap)
        ])
    }
    
    func setupInteractionButtons() {
        addSubview(rewindButton)
        addSubview(playButton)
        addSubview(forwardButton)
        
        rewindButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rewindButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -Sizes.edgeGap*8),
            rewindButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
            rewindButton.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: Sizes.interButtonMultiplier),
            rewindButton.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: Sizes.interButtonMultiplier),
            
            playButton.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
            playButton.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: Sizes.interButtonMultiplier),
            playButton.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: Sizes.interButtonMultiplier),
            
            forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: Sizes.edgeGap*8),
            forwardButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
            forwardButton.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: Sizes.interButtonMultiplier),
            forwardButton.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: Sizes.interButtonMultiplier),
        ])
    }
    
    func setupProgressBar() {
        addSubview(progressBar)
        addSubview(currentTimeLabel)
        addSubview(remainingTimeLabel)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressBar.bottomAnchor.constraint(equalTo: currentTimeLabel.topAnchor, constant: -Sizes.timeGap),
            progressBar.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: Sizes.edgeGap*2),
            progressBar.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -Sizes.edgeGap*2),
            progressBar.heightAnchor.constraint(equalToConstant: Sizes.progressSize),
            
            currentTimeLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -Sizes.edgeGap),
            currentTimeLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: Sizes.edgeGap*2),
            
            remainingTimeLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -Sizes.edgeGap),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -Sizes.edgeGap*2),
        ])
    }
}

// ------------ MARK: - Protocol implementation
extension MediaPlayerView: MediaPlayerViewProtocol {
    
    func setupSubviews() {
        self.backgroundColor = .black
        setupMusicIndicatorImageView()
        setupFilterView()
        setupWindowButtons()
        setupInfoLabel()
        setupTitleLabel()
        setupProgressBar()
        setupInteractionButtons()
        
        boundsObservation = observe(\.frame) { [weak self] kvo, change in
            guard let self else { return }
            presenter.onBoundsChange()
        }
    }
    
    func setupGesture() {
        addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(onViewTap))
        )
    }
    
    func setupPlayerLayer(_ layer: AVPlayerLayer?) {
        guard let layer else { return }
        self.layer.insertSublayer(layer, at: 0)
        self.playerLayer = layer
    }
    
    func layoutMediaLayers() {
        let safeFrame = frame.inset(by: self.safeAreaInsets)
        
        let x = safeAreaInsets.left
        let y = safeAreaInsets.top
        let origin = CGPoint(x: x, y: y)
        let newFrame = CGRect(
            origin: origin,
            size: safeFrame.size
        )
        
        playerLayer?.frame = newFrame
        playerLayer?.layoutIfNeeded()
        
        //TODO: -remove asset reading code and add musicIndicatorImage as a layer somehow
        //TODO: because it causes the app to stutter for a while until the view is loaded-
        //TODO: make "isVideo" detection as a self detection mechanism instead of taking it as a build parameter.
        /*if let asset = playerLayer?.player?.currentItem?.asset {
            print(asset.tracks.count)
            if asset.tracks.contains(where: {$0.mediaType == .video}) {
                musicIndicatorImageView.isHidden = true
            }
        }*/
        
        musicIndicatorImageView.isHidden = isVideo
    }
    
    func fadeOut() {
        isFiltered = false
        UIView.animate(withDuration: Animation.duration) { [weak self] in
            guard let self else { return }
            for view in subviews {
                if view.tag != -1 {
                    view.layer.opacity = 0.0
                }
            }
        }
    }
    
    func fadeIn() {
        isFiltered = true
        UIView.animate(withDuration: Animation.duration) { [weak self] in
            guard let self else { return }
            for view in subviews {
                if view.tag != 1 {
                    view.layer.opacity = Animation.viewOpacity
                }
            }
            blackFilterView.layer.opacity = Animation.filterOpacity
        }
    }
    
    func showPlay() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            playButton.setBackgroundImage(
                UIImage(systemName: SystemImages.playImage),
                for: .normal
            )
        }
    }
    
    func showPause() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            playButton.setBackgroundImage(
                UIImage(systemName: SystemImages.pauseImage),
                for: .normal
            )
        }
    }
    
    func setProgressBar(currentText: String, remainingText: String, progress: Float) {
        currentTimeLabel.text = currentText
        remainingTimeLabel.text = remainingText
        progressBar.setProgress(progress, animated: true)
    }
}

extension UIImage {
    class func imageWithColor(
        color: UIColor,
        size: CGSize=CGSize(width: 1, height: 1))
    -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
