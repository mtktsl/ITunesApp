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
    
    func setupImage(systemName: String)
    func setupImage(imageName: String)
    func setupImage(data: Data)
}

protocol SearchCellDelegate: AnyObject {
    func onPlayButtonTap()
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
        return titleLabel
    }()
    
    let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        return subtitleLabel
    }()
    
    let bodyLabel: UILabel = {
        let bodyLabel = UILabel()
        return bodyLabel
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var mainGrid = Grid.horizontal {
        imageView
            .Constant(value: 50)
        
        Grid.vertical {
            titleLabel
                .Auto()
            subtitleLabel
                .Auto()
            bodyLabel
                .Auto()
            
        }.Expanded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainGrid)
        NSLayoutConstraint.expand(mainGrid, to: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchCell: SearchCellProtocol {
    
    func setupCell(
        title: String?,
        subtitle: String?,
        body: String?
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        bodyLabel.text = body
        presenter.cellDidSetup()
    }
    
    func setupImage(data: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageView.image = UIImage(data: data)
        }
    }
    
    func setupImage(systemName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageView.image = UIImage(systemName: systemName)
        }
    }
    
    func setupImage(imageName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            imageView.image = UIImage(named: imageName)
        }
    }
}
