//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 12.06.2023.
//

import UIKit
import GridLayout

internal protocol ModalPickerControllerDelegate: AnyObject {
    func onFilterSelected(_ filter: String)
}

internal class ModalPickerController: UIViewController {
    
    weak var delegate: ModalPickerControllerDelegate?
    
    var collection = [String]()
    private var filteredCollection = [String]()
    
    var height: CGFloat = 0
    var horizontalInset: CGFloat = 0
    var minTableHeight: CGFloat = 200
    private var isFiltering: Bool = false
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self,
                               action: #selector(cancelTap(_:)),
                               for: .touchUpInside)
        cancelButton.backgroundColor = .systemGray
        return cancelButton
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    lazy var mainGrid = Grid.vertical {
        Grid.horizontal {
            UIView()
                .Constant(value: 100)
            titleLabel
                .Expanded()
            cancelButton
                .Constant(value: 100, margin: .init(top: 10, left: 10, bottom: 10, right: 10))
        }.Constant(value: 50)
        searchBar
            .Auto()
        tableView
            .Expanded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainGrid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainGrid.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainGrid.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        guard let window = view.window else { return }
        
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        
        
        let calculatedInset = window.safeAreaInsets.left
        + window.safeAreaInsets.right
        + horizontalInset
        
        let calculatedWidth = window.bounds.size.width
        - calculatedInset * 2
        
        let calculatedHeight = mainGrid.sizeThatFits(
            .init(width: calculatedWidth,
                  height: height)
        ).height + minTableHeight
        
        let finalHeight = height < calculatedHeight
                        ? calculatedHeight
                        : height
        
        let y = window.bounds.size.height
            - window.safeAreaInsets.top
            - window.safeAreaInsets.bottom
            - finalHeight
        
        view.frame = CGRect(x: calculatedInset,
                            y: y,
                            width: calculatedWidth,
                            height: finalHeight
        )
        
        mainGrid.setNeedsLayout()
    }
    
    @objc private func cancelTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ModalPickerController: UISearchBarDelegate {
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        isFiltering = !searchText.isEmpty
        filteredCollection = collection.filter(
            { $0.contains(searchText) }
        )
        tableView.reloadData()
    }
}

extension ModalPickerController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedFilter = isFiltering
        ? filteredCollection[indexPath.row]
        : collection[indexPath.row]
        delegate?.onFilterSelected(selectedFilter)
        dismiss(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return isFiltering
        ? filteredCollection.count
        : collection.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")
        else { fatalError("Failed to retreive default cell in modal picker controller") }
        
        let cellText = isFiltering
        ? filteredCollection[indexPath.row]
        : collection[indexPath.row]
        
        if #available(iOS 14, *) {
            var config = cell.defaultContentConfiguration()
            config.text = cellText
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = collection[indexPath.row]
        }
        return cell
    }
}
