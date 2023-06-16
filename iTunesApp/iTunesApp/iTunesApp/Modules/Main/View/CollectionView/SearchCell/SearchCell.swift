//
//  SearchCell.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import UIKit
import GridLayout

protocol SearchCellProtocol: AnyObject {
    func setupCell(
        title: String?,
        subtitle: String?,
        body: String?
    )
    
    func setupView()
    func setupImage(systemName: String)
    func setupImage(imageName: String)
    func setupImage(data: Data)
    func setupButtonImage(systemName: String)
    func resetViews()
    func notifyDelegate(_ urlString: String?)
}

protocol SearchCellDelegate: AnyObject {
    func onPlayButtonTap(_ urlString: String)
}

class SearchCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SearchCell"
    
    weak var delegate: SearchCellDelegate?
    
    var presenter: SearchCellPresenter! {
        didSet {
            presenter.cellDidInit()
        }
    }
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 16)
        return titleLabel
    }()
    
    let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.textColor = .gray
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        return subtitleLabel
    }()
    
    let bodyLabel: UILabel = {
        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 14, weight: .light)
        bodyLabel.textColor = .gray
        return bodyLabel
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var playButton: UIImageView = {
        let playButton = UIImageView()
        playButton.contentMode = .scaleAspectFit
        playButton.tintColor = .black
        playButton.isUserInteractionEnabled = true
        playButton.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(onPlayTap(_:))
            )
        )
        return playButton
    }()
    
    lazy var mainGrid = Grid.horizontal {
        imageView
            .Constant(
                value: .searchCellHomeHeight,
                margin: .searchCellImageMargin
            )
        
        Grid.vertical {
            titleLabel
                .Auto()
            subtitleLabel
                .Expanded(verticalAlignment: .autoBottom)
            bodyLabel
                .Expanded(verticalAlignment: .autoTop)
            
        }.Expanded(margin: .searchCellTextMargin)
        
        playButton
            .Constant(value: 50, margin: .init(0, 0, 0, 10))
    }
    
    override func prepareForReuse() {
        presenter.cellPrepare()
    }
    
    func setImageCornerRadius() {
        imageView.layer.cornerRadius = imageView.bounds.size.height / 2
    }
    
    @objc func onPlayTap(_ recognizer: UITapGestureRecognizer) {
        presenter.didTapPlay()
    }
}

extension SearchCell: SearchCellProtocol {
    func notifyDelegate(_ urlString: String?) {
        delegate?.onPlayButtonTap(urlString ?? "")
    }
    
    func setupButtonImage(systemName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            playButton.image = UIImage(systemName: systemName)
            mainGrid.setNeedsLayout()
        }
    }
    
    func resetViews() {
        titleLabel.text = ""
        subtitleLabel.text = ""
        bodyLabel.text = ""
    }
    
    func setupView() {
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainGrid)
        NSLayoutConstraint.expand(mainGrid, to: contentView)
        
        contentView.layer.cornerRadius = .searchCellRadius
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = (
            .searchCellHomeHeight
            - UIEdgeInsets.searchCellImageMargin.top
            - UIEdgeInsets.searchCellImageMargin.bottom
        ) / 2
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setupCell(
        title: String?,
        subtitle: String?,
        body: String?
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        if let body {
            bodyLabel.text = "Collection: " + body
        }
        presenter.cellDidSetup()
    }
    
    func setupImage(data: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageView.image = UIImage(data: data)
            mainGrid.setNeedsLayout()
            setImageCornerRadius()
        }
    }
    
    func setupImage(systemName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageView.image = UIImage(systemName: systemName)
            mainGrid.setNeedsLayout()
            setImageCornerRadius()
        }
    }
    
    func setupImage(imageName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageView.image = UIImage(named: imageName)
            mainGrid.setNeedsLayout()
            setImageCornerRadius()
        }
    }
}
