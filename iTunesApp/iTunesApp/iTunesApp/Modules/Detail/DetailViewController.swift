//
//  DetailViewController.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import UIKit
import GridLayout

protocol DetailViewControllerProtocol: AnyObject {
    func setupView()
    func setupLabels(
        trackName: String?,
        artistName: String?,
        collectionName: String?,
        genre: String?,
        trackPrice: Float?,
        collectionPrice: Float?,
        currency: String?
    )
    func setupImageView(_ data: Data)
    func setupImageView(assetName: String)
    func setupImageView(systemName: String)
    
    func setupButtonImageView(assetName: String)
    func setupButtonImageView(systemName: String)
    func setupFavImageView(assetName: String)
    func setupFavImageView(systemName: String)
    
    func showLoading()
    func showPopup(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((UIAlertAction) -> Void)?,
        onCancel: ((UIAlertAction) -> Void)?
    )
}

final class DetailViewController: BaseViewController {
    var presenter: DetailPresenterProtocol!
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let trackLabel: UILabel = {
        let trackNameLabel = UILabel()
        trackNameLabel.numberOfLines = 2
        trackNameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        trackNameLabel.textAlignment = .center
        return trackNameLabel
    }()
    
    let collectionLabel: UILabel = {
        let collectionNameLabel = UILabel()
        collectionNameLabel.textAlignment = .center
        collectionNameLabel.numberOfLines = 2
        return collectionNameLabel
    }()
    
    let artistLabel: UILabel = {
        let artistLabel = UILabel()
        artistLabel.textAlignment = .center
        return artistLabel
    }()
    
    lazy var playButtonImageView: UIImageView = {
        let playButtonImageView = UIImageView()
        playButtonImageView.contentMode = .scaleAspectFit
        playButtonImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(onPlayButtonTap(_:))
            )
        )
        playButtonImageView.isUserInteractionEnabled = true
        return playButtonImageView
    }()
    
    lazy var favButtonImageView: UIImageView = {
        let favButtonImageView = UIImageView()
        favButtonImageView.contentMode = .scaleAspectFit
        favButtonImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(onFavTap(_:))
            )
        )
        favButtonImageView.isUserInteractionEnabled = true
        return favButtonImageView
    }()
    
    let genreLabel: UILabel = {
        let genreLabel = UILabel()
        genreLabel.textAlignment = .center
        return genreLabel
    }()
    
    let trackPriceLabel: UILabel = {
        let trackPriceLabel = UILabel()
        trackPriceLabel.textAlignment = .center
        return trackPriceLabel
    }()
    
    let collectionPriceLabel: UILabel = {
        let collectionPriceLabel = UILabel()
        collectionPriceLabel.textAlignment = .center
        return collectionPriceLabel
    }()
    
    lazy var buttonArea = Grid.horizontal {
        UIView()
            .Expanded()
        
        playButtonImageView
            .Constant(value: 100)
        favButtonImageView
            .Constant(value: 100)
        
        UIView()
            .Expanded()
    }
    
    lazy var topContainer: Grid = {
        let container = Grid.vertical {
            imageView
                .Auto()
            
            trackLabel
                .Auto(margin: .init(3, 0))
            artistLabel
                .Auto(margin: .init(3, 0))
            collectionLabel
                .Auto(margin: .init(3, 0, 3))
        }
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.lightGray.cgColor
        return container
    }()
    
    lazy var middleContainer: Grid = {
        let container = Grid.vertical {
            buttonArea
                .Expanded(margin: .init(10, 0, 10))
        }
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.lightGray.cgColor
        return container
    }()
    
    lazy var bottomContainer: Grid = {
        let containter = Grid.vertical {
            genreLabel
                .Auto(margin: .init(5, 0))
            trackPriceLabel
                .Auto()
            collectionPriceLabel
                .Auto(margin: .init(0,0,5))
        }
        containter.layer.borderWidth = 1
        containter.layer.borderColor = UIColor.lightGray.cgColor
        return containter
    }()
    
    lazy var mainGrid = Grid.vertical {
        topContainer
            .Auto()
        middleContainer
            .Constant(value: 50)
        bottomContainer
            .Expanded(verticalAlignment: .autoTop)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidAppear()
    }
    
    @objc func onPlayButtonTap(_ recognizer: UITapGestureRecognizer) {
        presenter.onPlayTap()
    }
    
    @objc func onFavTap(_ recognizer: UITapGestureRecognizer) {
        presenter.onFavTap()
    }
    
    private func setImage(_ image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageView.image = image
            mainGrid.setNeedsLayout()
        }
    }
    
    private func setFavImage(_ image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            favButtonImageView.image = image
            mainGrid.setNeedsLayout()
        }
    }
    
    private func setPlayImage(_ image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            playButtonImageView.image = image
            mainGrid.setNeedsLayout()
        }
    }
}

extension DetailViewController: DetailViewControllerProtocol {
    func showPopup(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((UIAlertAction) -> Void)?,
        onCancel: ((UIAlertAction) -> Void)?
    ) {
        popupError(
            title: title,
            message: message,
            okOption: okOption,
            cancelOption: cancelOption,
            onOk: onOk,
            onCancel: onCancel
        )
    }
    
    func setupFavImageView(assetName: String) {
        setFavImage(UIImage(named: assetName))
    }
    
    func setupFavImageView(systemName: String) {
        setFavImage(UIImage(systemName: systemName))
    }
    
    func setupButtonImageView(assetName: String) {
        setPlayImage(UIImage(named: assetName))
    }
    
    func setupButtonImageView(systemName: String) {
        setPlayImage(UIImage(systemName: systemName))
    }
    
    func setupView() {
        view.backgroundColor = .white
        playButtonImageView.tintColor = .black
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainGrid)
        NSLayoutConstraint.expand(mainGrid, to: view.safeAreaLayoutGuide)
    }
    
    func setupLabels(
        trackName: String?,
        artistName: String?,
        collectionName: String?,
        genre: String?,
        trackPrice: Float?,
        collectionPrice: Float?,
        currency: String?
    ) {
        trackLabel.text = trackName
        artistLabel.text = artistName
        collectionLabel.text = collectionName
        genreLabel.text = genre
        
        guard let trackPrice,
              let currency,
              let collectionPrice
        else { return }
        
        trackPriceLabel.text = "Track Price: \(trackPrice) \(currency)"
        collectionPriceLabel.text = "Collection Price: \(collectionPrice) \(currency)"
        
        mainGrid.setNeedsLayout()
    }
    
    func setupImageView(_ data: Data) {
        setImage(UIImage(data: data))
    }
    
    func setupImageView(assetName: String) {
        setImage(UIImage(named: assetName))
    }
    
    func setupImageView(systemName: String) {
        setImage(UIImage(systemName: systemName))
    }
    
    func showLoading() {
        super.showLoading(on: imageView)
    }
}
